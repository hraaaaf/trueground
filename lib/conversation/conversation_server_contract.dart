const String conversationServerClientContract = 'tg11f.client.v1';

class ConversationServerHttpResponse {
  const ConversationServerHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}
