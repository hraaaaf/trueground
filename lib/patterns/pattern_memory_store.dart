import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const Duration patternMemoryRetention = Duration(days: 30);
const int patternMemoryMaxRecords = 30;

enum PatternEventKind {
  pausePractice,
  uncertaintyPractice,
  valuesStep,
}

extension PatternEventKindCopy on PatternEventKind {
  String get storageValue => switch (this) {
    PatternEventKind.pausePractice => 'pause_practice',
    PatternEventKind.uncertaintyPractice => 'uncertainty_practice',
    PatternEventKind.valuesStep => 'values_step',
  };

  String get userLabel => switch (this) {
    PatternEventKind.pausePractice => 'Paused before an urge-driven action',
    PatternEventKind.uncertaintyPractice => 'Practiced leaving uncertainty unresolved',
    PatternEventKind.valuesStep => 'Chose a values-based next step',
  };

  static PatternEventKind? fromStorageValue(String value) {
    for (final kind in PatternEventKind.values) {
      if (kind.storageValue == value) {
        return kind;
      }
    }
    return null;
  }
}

class PatternRecord {
  const PatternRecord({required this.kind, required this.occurredAt});

  final PatternEventKind kind;
  final DateTime occurredAt;

  Map<String, Object> toJson() => <String, Object>{
    'kind': kind.storageValue,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
  };

  static PatternRecord? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }
    final kindValue = value['kind'];
    final occurredAtValue = value['occurred_at'];
    if (kindValue is! String || occurredAtValue is! String) {
      return null;
    }
    final kind = PatternEventKindCopy.fromStorageValue(kindValue);
    final occurredAt = DateTime.tryParse(occurredAtValue)?.toUtc();
    if (kind == null || occurredAt == null) {
      return null;
    }
    return PatternRecord(kind: kind, occurredAt: occurredAt);
  }
}

abstract interface class PatternMemoryStore {
  Future<List<PatternRecord>> readRecords({required DateTime now});

  Future<void> append(PatternEventKind kind, {required DateTime occurredAt});

  Future<void> deleteKind(PatternEventKind kind);

  Future<void> deleteAll();
}

List<PatternRecord> retainPatternRecords(
  List<PatternRecord> records, {
  required DateTime now,
}) {
  final cutoff = now.toUtc().subtract(patternMemoryRetention);
  final retained = records
      .where(
        (record) =>
            !record.occurredAt.toUtc().isAfter(now.toUtc()) &&
            !record.occurredAt.toUtc().isBefore(cutoff),
      )
      .toList()
    ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  return retained.length > patternMemoryMaxRecords
      ? retained.sublist(retained.length - patternMemoryMaxRecords)
      : retained;
}

class SharedPreferencesPatternMemoryStore implements PatternMemoryStore {
  SharedPreferencesPatternMemoryStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String recordsKey = 'trueground.pattern_review.records.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<PatternRecord>> readRecords({required DateTime now}) async {
    final records = await _readRaw();
    final retained = retainPatternRecords(records, now: now.toUtc());
    if (retained.length != records.length) {
      await _write(retained);
    }
    return List<PatternRecord>.unmodifiable(retained);
  }

  @override
  Future<void> append(
    PatternEventKind kind, {
    required DateTime occurredAt,
  }) async {
    final now = occurredAt.toUtc();
    final records = retainPatternRecords(await _readRaw(), now: now)
      ..add(PatternRecord(kind: kind, occurredAt: now))
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    final bounded = records.length > patternMemoryMaxRecords
        ? records.sublist(records.length - patternMemoryMaxRecords)
        : records;
    await _write(bounded);
  }

  @override
  Future<void> deleteKind(PatternEventKind kind) async {
    final records = await _readRaw();
    await _write(records.where((record) => record.kind != kind).toList());
  }

  @override
  Future<void> deleteAll() async {
    await _preferences.remove(recordsKey);
  }

  Future<List<PatternRecord>> _readRaw() async {
    final raw = await _preferences.getString(recordsKey);
    if (raw == null) {
      return <PatternRecord>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Pattern memory is not a JSON list.');
    }

    final records = <PatternRecord>[];
    for (final item in decoded) {
      final record = PatternRecord.fromJson(item);
      if (record == null) {
        throw const FormatException('Pattern memory contains an invalid record.');
      }
      records.add(record);
    }
    return records;
  }

  Future<void> _write(List<PatternRecord> records) async {
    if (records.isEmpty) {
      await _preferences.remove(recordsKey);
      return;
    }
    await _preferences.setString(
      recordsKey,
      jsonEncode(records.map((record) => record.toJson()).toList()),
    );
  }
}
