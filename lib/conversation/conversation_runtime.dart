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
const Duration defaultConversationProviderTimeout = Duration(seconds: 15);

enum ConversationRuntimeDisposition { generated, deterministicOnly, failClosed }

class ConversationProviderRequest {
  const ConversationProviderRequest({
    required this.languageCode,
    required this.userMessage,
  });

  final String languageCode;
  final String userMessage;
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
    );
    if (guardDecision.isRejected) {
      return ConversationRuntimeResult(
        disposition: ConversationRuntimeDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
        outputGuardDecision: guardDecision,
      );
    }

    return ConversationRuntimeResult(
      disposition: ConversationRuntimeDisposition.generated,
      safetyDecision: safetyDecision,
      response: response,
      outputGuardDecision: guardDecision,
    );
  }

  ConversationRuntimeResult _failClosed() {
    return ConversationRuntimeResult(
      disposition: ConversationRuntimeDisposition.failClosed,
      safetyDecision: ConversationFailurePolicy.providerFailure(),
    );
  }
}
