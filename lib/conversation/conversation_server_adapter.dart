import 'dart:convert';

import 'conversation_runtime.dart';
import 'conversation_server_contract.dart';
import 'conversation_server_transport.dart';

typedef ConversationServerTransport =
    Future<ConversationServerHttpResponse> Function(String body);

class ServerConversationProviderAdapter implements ConversationProviderAdapter {
  ServerConversationProviderAdapter({ConversationServerTransport? transport})
    : _transport = transport ?? sendConversationServerRequest;

  final ConversationServerTransport _transport;

  @override
  Future<ConversationProviderInvocation> generate(
    ConversationProviderRequest request,
  ) async {
    final normalizedUserMessage = request.userMessage.trim();
    if (normalizedUserMessage.isEmpty ||
        normalizedUserMessage.length >
            conversationRuntimeMaxUserMessageLength ||
        request.context.length > conversationProviderContextMaxMessages ||
        request.context.any(
          (message) =>
              message.content.trim().isEmpty ||
              message.content.trim().length >
                  conversationRuntimeMaxUserMessageLength,
        )) {
      throw StateError('Conversation request outside bounded contract.');
    }

    final response = await _transport(
      jsonEncode(<String, Object?>{
        'schema_version': conversationRuntimeSchemaVersion,
        'language': request.languageCode,
        'user_message': normalizedUserMessage,
        'context': request.context
            .map(
              (message) => <String, Object?>{
                'role': message.role,
                'content': message.content,
              },
            )
            .toList(growable: false),
      }),
    );

    if (response.statusCode != 200) {
      throw StateError('Conversation provider unavailable.');
    }

    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw StateError('Conversation provider unavailable.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw StateError('Conversation provider unavailable.');
    }

    return ConversationProviderInvocation(
      payload: decoded.map<String, Object?>(
        (key, value) => MapEntry<String, Object?>(key, value),
      ),
    );
  }
}
