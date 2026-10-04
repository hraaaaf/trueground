import 'conversation_output_guard.dart';
import 'conversation_safety_policy.dart';

const String conversationRuntimeSchemaVersion = 'tg11c.response.v1';
const Set<String> conversationRuntimeRequiredKeys = <String>{
  'schema_version',
  'message',
  'language',
  'mode',
};
const Set<String> conversationRuntimeLanguages = <String>{'en', 'fr'};
const Set<String> conversationRuntimeModes = <String>{'support', 'clarify'};
const int conversationRuntimeMaxMessageLength = 1200;
const int conversationRuntimeMaxUserMessageLength = 1200;
const Duration defaultConversationProviderTimeout = Duration(seconds: 15);
const int conversationProviderContextMaxMessages = 4;

enum ConversationRuntimeDisposition { generated, deterministicOnly, failClosed }

class ConversationProviderContextMessage {
  const ConversationProviderContextMessage({
    required this.role,
    required this.content,
  });

  final String role;
  final String content;
}

class ConversationProviderRequest {
  const ConversationProviderRequest({
    required this.languageCode,
    required this.userMessage,
    this.context = const <ConversationProviderContextMessage>[],
  });

  final String languageCode;
  final String userMessage;
  final List<ConversationProviderContextMessage> context;
}

class ConversationProviderInvocation {
  const ConversationProviderInvocation({required this.payload});

  final Map<String, Object?> payload;
}

abstract interface class ConversationProviderAdapter {
  Future<ConversationProviderInvocation> generate(
    ConversationProviderRequest request,
  );
}

class ConversationGeneratedResponse {
  const ConversationGeneratedResponse({
    required this.message,
    required this.language,
    required this.mode,
  });

  final String message;
  final String language;
  final String mode;

  static ConversationGeneratedResponse? tryParse(Map<String, Object?> payload) {
    if (payload.length != conversationRuntimeRequiredKeys.length ||
        !conversationRuntimeRequiredKeys.every(payload.containsKey)) {
      return null;
    }

    if (payload['schema_version'] != conversationRuntimeSchemaVersion) {
      return null;
    }

    final message = payload['message'];
    final language = payload['language'];
    final mode = payload['mode'];

    if (message is! String ||
        message.isEmpty ||
        message.length > conversationRuntimeMaxMessageLength ||
        language is! String ||
        !conversationRuntimeLanguages.contains(language) ||
        mode is! String ||
        !conversationRuntimeModes.contains(mode)) {
      return null;
    }

    return ConversationGeneratedResponse(
      message: message,
      language: language,
      mode: mode,
    );
  }
}

class ConversationRuntimeResult {
  const ConversationRuntimeResult({
    required this.disposition,
    required this.safetyDecision,
    this.response,
    this.outputGuardDecision,
  });

  final ConversationRuntimeDisposition disposition;
  final ConversationDecision safetyDecision;
  final ConversationGeneratedResponse? response;
  final OutputGuardDecision? outputGuardDecision;
}

class BoundedConversationRuntime {
  BoundedConversationRuntime({
    required this.adapter,
    ConversationSafetySession? session,
    this.providerTimeout = defaultConversationProviderTimeout,
  }) : assert(providerTimeout.inMicroseconds > 0),
       session = session ?? ConversationSafetySession();

  final ConversationProviderAdapter adapter;
  final ConversationSafetySession session;
  final Duration providerTimeout;
  final List<ConversationProviderContextMessage> _providerContext =
      <ConversationProviderContextMessage>[];

  List<ConversationProviderContextMessage> get providerContext =>
      List<ConversationProviderContextMessage>.unmodifiable(_providerContext);

  void resetProviderContext() {
    _providerContext.clear();
  }

  Future<ConversationRuntimeResult> run(
    String userMessage, {
    String languageCode = 'en',
  }) async {
    final normalizedLanguage = languageCode == 'fr' ? 'fr' : 'en';
    final safetyDecision = session.evaluate(
      userMessage,
      languageCode: normalizedLanguage,
    );

    if (!safetyDecision.modelEligible) {
      return ConversationRuntimeResult(
        disposition: ConversationRuntimeDisposition.deterministicOnly,
        safetyDecision: safetyDecision,
      );
    }

    ConversationProviderInvocation invocation;
    try {
      invocation = await adapter
          .generate(
            ConversationProviderRequest(
              languageCode: normalizedLanguage,
              userMessage: userMessage,
              context: List<ConversationProviderContextMessage>.unmodifiable(
                _providerContext,
              ),
            ),
          )
          .timeout(providerTimeout);
    } catch (_) {
      return _failClosed();
    }

    final response = ConversationGeneratedResponse.tryParse(invocation.payload);
    if (response == null || response.language != normalizedLanguage) {
      return _failClosed();
    }

    final guardDecision = DeterministicConversationOutputGuard.inspect(
      response.message,
      inputRiskFamily: switch (safetyDecision.reasonCode) {
        ConversationReasonCode.reassurance => 'reassurance',
        ConversationReasonCode.rumination => 'rumination',
        ConversationReasonCode.confession => 'confession',
        _ => null,
      },
    );
    if (guardDecision.isRejected) {
      return ConversationRuntimeResult(
        disposition: ConversationRuntimeDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
        outputGuardDecision: guardDecision,
      );
    }

    _rememberProviderTurn(userMessage, response.message);

    return ConversationRuntimeResult(
      disposition: ConversationRuntimeDisposition.generated,
      safetyDecision: safetyDecision,
      response: response,
      outputGuardDecision: guardDecision,
    );
  }

  void _rememberProviderTurn(String userMessage, String assistantMessage) {
    _providerContext
      ..add(
        ConversationProviderContextMessage(role: 'user', content: userMessage),
      )
      ..add(
        ConversationProviderContextMessage(
          role: 'assistant',
          content: assistantMessage,
        ),
      );

    while (_providerContext.length > conversationProviderContextMaxMessages) {
      _providerContext.removeAt(0);
    }
  }

  ConversationRuntimeResult _failClosed() {
    return ConversationRuntimeResult(
      disposition: ConversationRuntimeDisposition.failClosed,
      safetyDecision: ConversationFailurePolicy.providerFailure(),
    );
  }
}
