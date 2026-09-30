import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trueground/conversation/conversation_runtime.dart';
import 'package:trueground/conversation/conversation_safety_policy.dart';
import 'package:trueground/conversation/conversation_server_adapter.dart';
import 'package:trueground/conversation/conversation_server_contract.dart';

void main() {
  group('LOT11-F live provider boundary', () {
    test('adapter sends only the strict server request contract', () async {
      String? captured;
      final adapter = ServerConversationProviderAdapter(
        transport: (body) async {
          captured = body;
          return const ConversationServerHttpResponse(
            statusCode: 200,
            body:
                '{"schema_version":"tg11c.response.v1","message":"Choose one small next step without resolving the uncertainty.","language":"en","mode":"support"}',
          );
        },
      );

      final invocation = await adapter.generate(
        const ConversationProviderRequest(
          languageCode: 'en',
          userMessage: 'Help me choose one useful next step.',
        ),
      );

      final sent = jsonDecode(captured!) as Map<String, dynamic>;
      expect(sent.keys.toSet(), {
        'schema_version',
        'language',
        'user_message',
        'context',
      });
      expect(sent['schema_version'], conversationRuntimeSchemaVersion);
      expect(sent['language'], 'en');
      expect(sent['user_message'], 'Help me choose one useful next step.');
      expect(sent['context'], isEmpty);
      expect(invocation.payload['language'], 'en');
    });

    test('adapter serializes bounded ephemeral context', () async {
      String? captured;
      final adapter = ServerConversationProviderAdapter(
        transport: (body) async {
          captured = body;
          return const ConversationServerHttpResponse(
            statusCode: 200,
            body:
                '{"schema_version":"tg11c.response.v1","message":"Choose one small next step without resolving the uncertainty.","language":"en","mode":"support"}',
          );
        },
      );

      await adapter.generate(
        const ConversationProviderRequest(
          languageCode: 'en',
          userMessage: 'What next?',
          context: <ConversationProviderContextMessage>[
            ConversationProviderContextMessage(
              role: 'user',
              content: 'I had a difficult morning.',
            ),
            ConversationProviderContextMessage(
              role: 'assistant',
              content: 'Choose one small grounded action.',
            ),
          ],
        ),
      );

      final sent = jsonDecode(captured!) as Map<String, dynamic>;
      final context = sent['context'] as List<dynamic>;
      expect(context, hasLength(2));
      expect(context.first, {
        'role': 'user',
        'content': 'I had a difficult morning.',
      });
      expect(context.last, {
        'role': 'assistant',
        'content': 'Choose one small grounded action.',
      });
    });

    test('non-200 server response fails closed through runtime', () async {
      final adapter = ServerConversationProviderAdapter(
        transport: (_) async => const ConversationServerHttpResponse(
          statusCode: 502,
          body: '{"error":"provider_unavailable"}',
        ),
      );
      final runtime = BoundedConversationRuntime(adapter: adapter);

      final result = await runtime.run('Help me choose one useful next step.');

      expect(result.disposition, ConversationRuntimeDisposition.failClosed);
      expect(
        result.safetyDecision.reasonCode,
        ConversationReasonCode.providerFailure,
      );
      expect(result.response, isNull);
    });

    test('malformed server JSON fails closed through runtime', () async {
      final adapter = ServerConversationProviderAdapter(
        transport: (_) async => const ConversationServerHttpResponse(
          statusCode: 200,
          body: 'not-json',
        ),
      );
      final runtime = BoundedConversationRuntime(adapter: adapter);

      final result = await runtime.run('Help me choose one useful next step.');

      expect(result.disposition, ConversationRuntimeDisposition.failClosed);
      expect(result.response, isNull);
    });

    test('wrong-language server payload is rejected by runtime', () async {
      final adapter = ServerConversationProviderAdapter(
        transport: (_) async => const ConversationServerHttpResponse(
          statusCode: 200,
          body:
              '{"schema_version":"tg11c.response.v1","message":"On peut laisser la question ouverte.","language":"fr","mode":"support"}',
        ),
      );
      final runtime = BoundedConversationRuntime(adapter: adapter);

      final result = await runtime.run(
        'Help me choose one useful next step.',
        languageCode: 'en',
      );

      expect(result.disposition, ConversationRuntimeDisposition.failClosed);
      expect(result.response, isNull);
    });

    test('deterministic diagnosis boundary never reaches server', () async {
      var calls = 0;
      final adapter = ServerConversationProviderAdapter(
        transport: (_) async {
          calls += 1;
          throw StateError('must not be called');
        },
      );
      final runtime = BoundedConversationRuntime(adapter: adapter);

      final result = await runtime.run('Diagnose me. Do I have OCD?');

      expect(
        result.disposition,
        ConversationRuntimeDisposition.deterministicOnly,
      );
      expect(result.safetyDecision.outcome, ConversationOutcome.claimBoundary);
      expect(calls, 0);
    });

    test('repeated reassurance reaches server once then pivots', () async {
      var calls = 0;
      final adapter = ServerConversationProviderAdapter(
        transport: (_) async {
          calls += 1;
          return const ConversationServerHttpResponse(
            statusCode: 200,
            body:
                '{"schema_version":"tg11c.response.v1","message":"We can leave the uncertainty unresolved and choose the next action.","language":"en","mode":"support"}',
          );
        },
      );
      final runtime = BoundedConversationRuntime(adapter: adapter);

      final first = await runtime.run('Can you promise I am a good person?');
      final second = await runtime.run('Are you sure I am a good person?');

      expect(first.disposition, ConversationRuntimeDisposition.generated);
      expect(
        second.disposition,
        ConversationRuntimeDisposition.deterministicOnly,
      );
      expect(second.safetyDecision.outcome, ConversationOutcome.routeLoop);
      expect(calls, 1);
    });

    test('client source contains no provider secret or raw logging', () {
      const paths = <String>[
        'lib/conversation/conversation_server_adapter.dart',
        'lib/conversation/conversation_server_transport.dart',
        'lib/conversation/conversation_server_transport_stub.dart',
        'lib/conversation/conversation_server_transport_web.dart',
      ];
      final combined = paths
          .map((path) => File(path).readAsStringSync())
          .join();

      expect(combined, isNot(contains('GROQ_API_KEY')));
      expect(combined, isNot(contains('api.groq.com')));
      expect(combined, isNot(contains('Bearer ')));
      expect(combined, isNot(contains('print(')));
      expect(combined, isNot(contains('debugPrint')));
      expect(combined, isNot(contains('logger')));
      expect(combined, isNot(contains('analytics')));
    });
  });
}
