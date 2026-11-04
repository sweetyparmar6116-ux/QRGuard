import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_record.dart';

class HistoryService {
  HistoryService({SharedPreferences? preferences})
      : _providedPreferences = preferences;

  static const String storageKey = 'qrguard.scan_history.v1';
  static const Duration duplicateWindow = Duration(seconds: 3);

  final SharedPreferences? _providedPreferences;

  Future<SharedPreferences> get _preferences async =>
      _providedPreferences ?? await SharedPreferences.getInstance();

  Future<List<ScanRecord>> getRecords() async {
    final preferences = await _preferences;
    final encoded = preferences.getString(storageKey);
    if (encoded == null || encoded.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const [];
      final records = <ScanRecord>[];
      for (final item in decoded) {
        try {
          if (item is Map) {
            records.add(ScanRecord.fromJson(Map<String, dynamic>.from(item)));
          }
        } on FormatException {
          // Skip a malformed entry while preserving the remaining records.
        } on TypeError {
          // Skip an entry with incompatible serialized field types.
        }
      }
      records.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return List.unmodifiable(records);
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  /// Returns false when an equivalent record was stored within the short
  /// repeat-detection window, or true when a new record was persisted.
  Future<bool> addRecord(ScanRecord record) async {
    final records = (await getRecords()).toList();
    final duplicate = records.any((existing) =>
        existing.content == record.content &&
        record.scannedAt.difference(existing.scannedAt).abs() <=
            duplicateWindow);
    if (duplicate) return false;

    records.add(record);
    records.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    final preferences = await _preferences;
    final saved = await preferences.setString(
      storageKey,
      jsonEncode(records.map((item) => item.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save scan history on this device.');
    return true;
  }

  Future<void> clearHistory() async {
    final preferences = await _preferences;
    final removed = await preferences.remove(storageKey);
    if (!removed && preferences.containsKey(storageKey)) {
      throw StateError('Could not clear scan history on this device.');
    }
  }
}