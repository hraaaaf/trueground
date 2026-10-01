import 'conversation_server_contract.dart';

Future<ConversationServerHttpResponse> sendConversationServerRequest(
  String body,
) {
  return Future<ConversationServerHttpResponse>.error(
    StateError('Live conversation transport is unavailable on this platform.'),
  );
}
