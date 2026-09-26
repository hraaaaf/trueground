import '../../lib/conversation/conversation_output_guard.dart';
import '../../lib/conversation/conversation_safety_policy.dart';

const String lot11cResponseSchemaVersion = 'tg11c.response.v1';

enum BenchmarkRunAuthorization {
  offlineOnly,
  syntheticModelEval,
}

enum BenchmarkRunDisposition {
  deterministicOnly,
  accepted,
  failClosed,
}

class BenchmarkFixture {
  const BenchmarkFixture({
    required this.id,
    required this.languageCode,
    required this.userMessage,
    this.isSynthetic = true,
  });

  final String id;
  final String languageCode;
  final String userMessage;
  final bool isSynthetic;
}

class BenchmarkRequestEnvelope {
  const BenchmarkRequestEnvelope({
    required this.fixtureId,
    required this.languageCode,
    required this.userMessage,
    required this.model,
    this.reasoningEffort = 'medium',
    this.strictStructuredOutput = true,
  });

  final String fixtureId;
  final String languageCode;
  final String userMessage;
  final String model;
  final String reasoningEffort;
  final bool strictStructuredOutput;
}

class BenchmarkResponseEnvelope {
  const BenchmarkResponseEnvelope({
    required this.schemaVersion,
    required this.message,
    required this.language,
    required this.mode,
  });

  final String schemaVersion;
  final String message;
  final String language;
  final String mode;

  static BenchmarkResponseEnvelope? tryParse(Map<String, Object?> json) {
    const expectedKeys = <String>{
      'schema_version',
      'message',
      'language',
      'mode',
    };
    if (json.keys.toSet().length != expectedKeys.length ||
        !json.keys.toSet().containsAll(expectedKeys)) {
      return null;
    }

    final schemaVersion = json['schema_version'];
    final message = json['message'];
    final language = json['language'];
    final mode = json['mode'];

    if (schemaVersion != lot11cResponseSchemaVersion ||
        message is! String ||
        message.trim().isEmpty ||
        message.length > 1200 ||
        (language != 'en' && language != 'fr') ||
        (mode != 'support' && mode != 'clarify')) {
      return null;
    }

    return BenchmarkResponseEnvelope(
      schemaVersion: schemaVersion as String,
      message: message,
      language: language as String,
      mode: mode as String,
    );
  }
}

abstract interface class BenchmarkProviderAdapter {
  String get providerName;
  String get modelName;

  /// True only for an adapter that can make an external provider call.
  bool get requiresNetwork;

  Future<ProviderInvocationResult> invoke(BenchmarkRequestEnvelope request);
}

class ProviderInvocationResult {
  const ProviderInvocationResult({
    required this.payload,
    required this.inputTokens,
    required this.outputTokens,
    this.reasoningTokens,
    this.retryCount = 0,
  });

  final Map<String, Object?> payload;
  final int inputTokens;
  final int outputTokens;
  final int? reasoningTokens;
  final int retryCount;
}

class ProviderPricing {
  const ProviderPricing({
    required this.inputUsdPerMillion,
    required this.outputUsdPerMillion,
  });

  final double inputUsdPerMillion;
  final double outputUsdPerMillion;

  double estimateUsd({
    required int inputTokens,
    required int outputTokens,
  }) {
    return (inputTokens / 1000000) * inputUsdPerMillion +
        (outputTokens / 1000000) * outputUsdPerMillion;
  }
}

class BenchmarkMetricRecord {
  const BenchmarkMetricRecord({
    required this.fixtureId,
    required this.provider,
    required this.model,
    required this.latencyMs,
    required this.inputTokens,
    required this.outputTokens,
    required this.reasoningTokens,
    required this.retryCount,
    required this.malformed,
    required this.guardRejected,
    required this.costUsd,
  });

  final String fixtureId;
  final String provider;
  final String model;
  final int latencyMs;
  final int inputTokens;
  final int outputTokens;
  final int? reasoningTokens;
  final int retryCount;
  final bool malformed;
  final bool guardRejected;
  final double costUsd;

  Map<String, Object?> toSanitizedJson() => <String, Object?>{
        'fixture_id': fixtureId,
        'provider': provider,
        'model': model,
        'latency_ms': latencyMs,
        'input_tokens': inputTokens,
        'output_tokens': outputTokens,
        'reasoning_tokens': reasoningTokens,
        'retry_count': retryCount,
        'malformed': malformed,
        'guard_rejected': guardRejected,
        'cost_usd': costUsd,
      };
}

class BenchmarkRunResult {
  const BenchmarkRunResult({
    required this.disposition,
    required this.safetyDecision,
    this.response,
    this.outputGuardDecision,
    this.metrics,
  });

  final BenchmarkRunDisposition disposition;
  final ConversationDecision safetyDecision;
  final BenchmarkResponseEnvelope? response;
  final OutputGuardDecision? outputGuardDecision;
  final BenchmarkMetricRecord? metrics;
}

class Lot11cBenchmarkRunner {
  Lot11cBenchmarkRunner({
    required this.adapter,
    required this.pricing,
    this.authorization = BenchmarkRunAuthorization.offlineOnly,
    ConversationSafetySession? session,
  }) : session = session ?? ConversationSafetySession();

  final BenchmarkProviderAdapter adapter;
  final ProviderPricing pricing;
  final BenchmarkRunAuthorization authorization;
  final ConversationSafetySession session;

  Future<BenchmarkRunResult> run(BenchmarkFixture fixture) async {
    if (!fixture.isSynthetic) {
      return BenchmarkRunResult(
        disposition: BenchmarkRunDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
      );
    }

    final safetyDecision = session.evaluate(
      fixture.userMessage,
      languageCode: fixture.languageCode,
    );

    if (!safetyDecision.modelEligible) {
      return BenchmarkRunResult(
        disposition: BenchmarkRunDisposition.deterministicOnly,
        safetyDecision: safetyDecision,
      );
    }

    if (adapter.requiresNetwork &&
        authorization != BenchmarkRunAuthorization.syntheticModelEval) {
      return BenchmarkRunResult(
        disposition: BenchmarkRunDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
      );
    }

    final request = BenchmarkRequestEnvelope(
      fixtureId: fixture.id,
      languageCode: fixture.languageCode,
      userMessage: fixture.userMessage,
      model: adapter.modelName,
    );

    final stopwatch = Stopwatch()..start();
    ProviderInvocationResult invocation;
    try {
      invocation = await adapter.invoke(request);
    } catch (_) {
      stopwatch.stop();
      return BenchmarkRunResult(
        disposition: BenchmarkRunDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
      );
    }
    stopwatch.stop();

    final response = BenchmarkResponseEnvelope.tryParse(invocation.payload);
    if (response == null) {
      return BenchmarkRunResult(
        disposition: BenchmarkRunDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
        metrics: BenchmarkMetricRecord(
          fixtureId: fixture.id,
          provider: adapter.providerName,
          model: adapter.modelName,
          latencyMs: stopwatch.elapsedMilliseconds,
          inputTokens: invocation.inputTokens,
          outputTokens: invocation.outputTokens,
          reasoningTokens: invocation.reasoningTokens,
          retryCount: invocation.retryCount,
          malformed: true,
          guardRejected: false,
          costUsd: pricing.estimateUsd(
            inputTokens: invocation.inputTokens,
            outputTokens: invocation.outputTokens,
          ),
        ),
      );
    }

    if (response.language != fixture.languageCode) {
      return BenchmarkRunResult(
        disposition: BenchmarkRunDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
        response: response,
        metrics: BenchmarkMetricRecord(
          fixtureId: fixture.id,
          provider: adapter.providerName,
          model: adapter.modelName,
          latencyMs: stopwatch.elapsedMilliseconds,
          inputTokens: invocation.inputTokens,
          outputTokens: invocation.outputTokens,
          reasoningTokens: invocation.reasoningTokens,
          retryCount: invocation.retryCount,
          malformed: true,
          guardRejected: false,
          costUsd: pricing.estimateUsd(
            inputTokens: invocation.inputTokens,
            outputTokens: invocation.outputTokens,
          ),
        ),
      );
    }

    final guardDecision =
        DeterministicConversationOutputGuard.inspect(response.message);
    final metrics = BenchmarkMetricRecord(
      fixtureId: fixture.id,
      provider: adapter.providerName,
      model: adapter.modelName,
      latencyMs: stopwatch.elapsedMilliseconds,
      inputTokens: invocation.inputTokens,
      outputTokens: invocation.outputTokens,
      reasoningTokens: invocation.reasoningTokens,
      retryCount: invocation.retryCount,
      malformed: false,
      guardRejected: guardDecision.isRejected,
      costUsd: pricing.estimateUsd(
        inputTokens: invocation.inputTokens,
        outputTokens: invocation.outputTokens,
      ),
    );

    if (guardDecision.isRejected) {
      return BenchmarkRunResult(
        disposition: BenchmarkRunDisposition.failClosed,
        safetyDecision: ConversationFailurePolicy.providerFailure(),
        response: response,
        outputGuardDecision: guardDecision,
        metrics: metrics,
      );
    }

    return BenchmarkRunResult(
      disposition: BenchmarkRunDisposition.accepted,
      safetyDecision: safetyDecision,
      response: response,
      outputGuardDecision: guardDecision,
      metrics: metrics,
    );
  }
}
