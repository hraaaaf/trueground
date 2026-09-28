import 'conversation_server_contract.dart';
import 'conversation_server_transport_stub.dart'
    if (dart.library.js_interop) 'conversation_server_transport_web.dart'
    as platform;

Future<ConversationServerHttpResponse> sendConversationServerRequest(
  String body,
) {
  return platform.sendConversationServerRequest(body);
}
