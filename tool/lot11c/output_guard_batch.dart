import 'dart:convert';
import 'dart:io';

import 'package:trueground/conversation/conversation_output_guard.dart';

Future<void> main() async {
  final raw = await stdin.transform(utf8.decoder).join();
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    stderr.writeln('Expected a JSON list');
    exitCode = 2;
    return;
  }

  final results = <Map<String, Object?>>[];
  for (final item in decoded) {
    if (item is! Map) {
      stderr.writeln('Invalid item');
      exitCode = 2;
      return;
    }
    final id = item['id'];
    final message = item['message'];
    if (id is! String || message is! String) {
      stderr.writeln('Invalid id/message');
      exitCode = 2;
      return;
    }
    final decision = DeterministicConversationOutputGuard.inspect(message);
    results.add(<String, Object?>{
      'id': id,
      'rejected': decision.isRejected,
      'violation': decision.violation.name,
    });
  }

  stdout.write(jsonEncode(results));
}
