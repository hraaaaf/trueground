import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'conversation_server_contract.dart';

Future<ConversationServerHttpResponse> sendConversationServerRequest(
  String body,
) async {
  final headers = web.Headers();
  headers.set('content-type', 'application/json');
  headers.set('x-trueground-client', conversationServerClientContract);

  final request = web.Request(
    '/api/conversation'.toJS,
    web.RequestInit(
      method: 'POST',
      headers: headers,
      body: body.toJS,
      credentials: 'same-origin',
    ),
  );
  final response = await web.window.fetch(request).toDart;
  final responseBody = (await response.text().toDart).toDart;

  return ConversationServerHttpResponse(
    statusCode: response.status,
    body: responseBody,
  );
}
