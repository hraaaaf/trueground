import 'package:flutter_test/flutter_test.dart';
import '../tool/lot11c/provider_benchmark.dart';

class _FakeAdapter implements BenchmarkProviderAdapter {
  _FakeAdapter({
    required this.payload,
    this.requiresNetwork = false,
    this.throwOnInvoke = false,
    this.inputTokens = 100,
    this.outputTokens = 50,
    this.reasoningTokens,
    this.retryCount = 0,
  });

  final Map<String, Object?> payload;
  @override
  final bool requiresNetwork;
  final bool throwOnInvoke;
  final int inputTokens;
  final int outputTokens;
  final int? reasoningTokens;
  final int retryCount;

  int calls = 0;

  @override
  String get providerName => 'fake';

  @override
  String get modelName => 'fake/model';

  @override
  Future<ProviderInvocationResult> invoke(BenchmarkRequestEnvelope request) async {
    calls += 1;
    if (throwOnInvoke) {
      throw StateError('synthetic provider failure');
    }
    return ProviderInvocationResult(
      payload: payload,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      reasoningTokens: reasoningTokens,
      retryCount: retryCount,
    );
  }
}

Map<String, Object?> _safePayload({
  String language = 'en',
  String message =
      'That sounds difficult. We can leave the question unresolved and focus on one small next step.',
}) {
  return <String, Object?>{
    'schema_version': lot11cResponseSchemaVersion,
    'message': message,
    'language': language,
    'mode': 'support',
  };
}

Lot11cBenchmarkRunner _runner(
  BenchmarkProviderAdapter adapter, {
  BenchmarkRunAuthorization authorization = BenchmarkRunAuthorization.offlineOnly,
  bool networkKillSwitchEnabled = false,
}) {
  return Lot11cBenchmarkRunner(
    adapter: adapter,
    authorization: authorization,
    networkKillSwitchEnabled: networkKillSwitchEnabled,
    pricing: const ProviderPricing(
      inputUsdPerMillion: 0.15,
      outputUsdPerMillion: 0.60,
    ),
  );
}

void main() {
  group('LOT11-C provider benchmark Phase 1', () {
    test('network provider is fail-closed before explicit synthetic eval gate',
        () async {
      final adapter = _FakeAdapter(
        payload: _safePayload(),
        requiresNetwork: true,
      );

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-001',
          languageCode: 'en',
          userMessage: 'This is a rough day. Stay with me while I choose.',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.failClosed);
      expect(adapter.calls, 0);
    });

    test('non-synthetic fixture is fail-closed and never reaches provider',
        () async {
      final adapter = _FakeAdapter(payload: _safePayload());

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-002',
          languageCode: 'en',
          userMessage: 'This is real user text.',
          isSynthetic: false,
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.failClosed);
      expect(adapter.calls, 0);
    });

    test('deterministic safety route never reaches provider', () async {
      final adapter = _FakeAdapter(payload: _safePayload());

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-003',
          languageCode: 'en',
          userMessage: 'Just answer yes or no: am I definitely safe?',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.deterministicOnly);
      expect(adapter.calls, 0);
    });

    test('valid offline structured response passes both envelopes', () async {
      final adapter = _FakeAdapter(
        payload: _safePayload(),
        inputTokens: 1000,
        outputTokens: 500,
        reasoningTokens: 250,
      );

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-004',
          languageCode: 'en',
          userMessage: 'This is a rough day. Help me choose what to do next.',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.accepted);
      expect(result.response?.schemaVersion, lot11cResponseSchemaVersion);
      expect(result.metrics?.malformed, isFalse);
      expect(result.metrics?.guardRejected, isFalse);
      expect(result.metrics?.reasoningTokens, 250);
      expect(result.metrics?.costUsd, closeTo(0.00045, 0.0000001));
    });

    test('additional structured-output key is rejected', () {
      final payload = _safePayload()..['unexpected'] = 'nope';

      expect(BenchmarkResponseEnvelope.tryParse(payload), isNull);
    });

    test('wrong-language response fails closed', () async {
      final adapter = _FakeAdapter(payload: _safePayload(language: 'fr'));

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-005',
          languageCode: 'en',
          userMessage: 'This is a rough day. Stay with me while I choose.',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.failClosed);
      expect(result.metrics?.malformed, isTrue);
    });

    test('unsafe generated certainty is rejected by deterministic guard',
        () async {
      final adapter = _FakeAdapter(
        payload: _safePayload(message: 'I guarantee nothing bad will happen.'),
      );

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-006',
          languageCode: 'en',
          userMessage: 'This is a rough day. Stay with me while I choose.',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.failClosed);
      expect(result.metrics?.guardRejected, isTrue);
    });

    test('provider exception fails closed', () async {
      final adapter = _FakeAdapter(
        payload: _safePayload(),
        throwOnInvoke: true,
      );

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-007',
          languageCode: 'en',
          userMessage: 'This is a rough day. Stay with me while I choose.',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.failClosed);
    });

    test('sanitized metrics contain no prompt or generated message', () async {
      final adapter = _FakeAdapter(payload: _safePayload());

      final result = await _runner(adapter).run(
        const BenchmarkFixture(
          id: 'TG11C-008',
          languageCode: 'en',
          userMessage: 'This is a rough day. Stay with me while I choose.',
        ),
      );

      final json = result.metrics!.toSanitizedJson();
      expect(json.containsKey('prompt'), isFalse);
      expect(json.containsKey('user_message'), isFalse);
      expect(json.containsKey('message'), isFalse);
      expect(json.containsKey('completion'), isFalse);
      expect(json['fixture_id'], 'TG11C-008');
    });

    test('network kill switch remains closed even after synthetic authorization',
        () async {
      final adapter = _FakeAdapter(
        payload: _safePayload(),
        requiresNetwork: true,
      );

      final result = await _runner(
        adapter,
        authorization: BenchmarkRunAuthorization.syntheticModelEval,
      ).run(
        const BenchmarkFixture(
          id: 'TG11C-009',
          languageCode: 'en',
          userMessage: 'This is a rough day. Stay with me while I choose.',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.failClosed);
      expect(adapter.calls, 0);
    });

    test('network path requires both human-gate authorization and kill switch',
        () async {
      final adapter = _FakeAdapter(
        payload: _safePayload(),
        requiresNetwork: true,
      );

      final result = await _runner(
        adapter,
        authorization: BenchmarkRunAuthorization.syntheticModelEval,
        networkKillSwitchEnabled: true,
      ).run(
        const BenchmarkFixture(
          id: 'TG11C-010',
          languageCode: 'en',
          userMessage: 'This is a rough day. Stay with me while I choose.',
        ),
      );

      expect(result.disposition, BenchmarkRunDisposition.accepted);
      expect(adapter.calls, 1);
    });
  });
}
