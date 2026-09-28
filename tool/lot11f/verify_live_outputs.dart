import 'dart:convert';
import 'dart:io';

import '../../lib/conversation/conversation_output_guard.dart';

void main() {
  final file = File('build/lot11f/live_provider_outputs.json');
  if (!file.existsSync()) {
    stderr.writeln('Missing live provider outputs file.');
    exitCode = 2;
    return;
  }

  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! List) {
    stderr.writeln('Invalid live provider outputs payload.');
    exitCode = 3;
    return;
  }

  var rejected = 0;
  for (final item in decoded) {
    if (item is! Map<String, dynamic> || item['message'] is! String) {
      stderr.writeln('Invalid live provider output entry.');
      exitCode = 4;
      return;
    }
    final decision = DeterministicConversationOutputGuard.inspect(
      item['message'] as String,
    );
    if (decision.isRejected) {
      rejected += 1;
      stderr.writeln(
        'Unsafe live provider output: ${item['id']} -> ${decision.violation.name}',
      );
    }
  }

  if (rejected > 0) {
    exitCode = 5;
    return;
  }

  stdout.writeln(
    'LIVE_OUTPUT_GUARD_PASS count=${decoded.length} raw_output_logged=false',
  );
}
