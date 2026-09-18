import 'package:shared_preferences/shared_preferences.dart';

const Duration practiceAntiReplayWindow = Duration(hours: 2);

bool isPracticeAntiReplayActive(
  DateTime? completedAt, {
  required DateTime now,
}) {
  if (completedAt == null) {
    return false;
  }

  final elapsed = now.toUtc().difference(completedAt.toUtc());
  return !elapsed.isNegative && elapsed < practiceAntiReplayWindow;
}

abstract interface class PracticeCompletionStore {
  Future<DateTime?> readPauseCompletedAt();

  Future<DateTime?> readUncertaintyCompletedAt();

  Future<void> writePauseCompletedAt(DateTime completedAt);

  Future<void> writeUncertaintyCompletedAt(DateTime completedAt);
}

class SharedPreferencesPracticeCompletionStore
    implements PracticeCompletionStore {
  SharedPreferencesPracticeCompletionStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String pauseCompletedAtKey =
      'trueground.practice.pause.completed_at.v1';
  static const String uncertaintyCompletedAtKey =
      'trueground.practice.uncertainty.completed_at.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<DateTime?> readPauseCompletedAt() async {
    return _readTimestamp(pauseCompletedAtKey);
  }

  @override
  Future<DateTime?> readUncertaintyCompletedAt() async {
    return _readTimestamp(uncertaintyCompletedAtKey);
  }

  @override
  Future<void> writePauseCompletedAt(DateTime completedAt) async {
    await _preferences.setString(
      pauseCompletedAtKey,
      completedAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> writeUncertaintyCompletedAt(DateTime completedAt) async {
    await _preferences.setString(
      uncertaintyCompletedAtKey,
      completedAt.toUtc().toIso8601String(),
    );
  }

  Future<DateTime?> _readTimestamp(String key) async {
    final value = await _preferences.getString(key);
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
}
