import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madl_project/models/analysis_result.dart';
import 'package:madl_project/models/scan_record.dart';
import 'package:madl_project/services/history_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ScanRecord record(String content, DateTime time) => ScanRecord(
        content: content,
        isValidUrl: true,
        riskLevel: RiskLevel.low,
        scannedAt: time,
        summary: 'No configured warnings.',
        findings: const [
          Finding(
            title: 'HTTPS connection',
            description: 'Encrypted, but not a trust guarantee.',
            isWarning: false,
          ),
        ],
      );

  test('saves and loads records newest first with findings', () async {
    final service = HistoryService();
    final now = DateTime(2026, 10, 20, 12);
    await service.addRecord(record('https://older.example', now));
    await service.addRecord(record('https://newer.example', now.add(const Duration(minutes: 1))));

    final records = await service.getRecords();
    expect(records.map((item) => item.content), [
      'https://newer.example',
      'https://older.example',
    ]);
    expect(records.last.findings.single.title, 'HTTPS connection');
    expect(records.last.riskLevel, RiskLevel.low);
  });

  test('returns empty history for empty and malformed stored JSON', () async {
    SharedPreferences.setMockInitialValues({HistoryService.storageKey: '{bad'});
    expect(await HistoryService().getRecords(), isEmpty);

    SharedPreferences.setMockInitialValues({HistoryService.storageKey: '[]'});
    expect(await HistoryService().getRecords(), isEmpty);
  });

  test('skips a malformed record but keeps valid records', () async {
    final good = record('https://valid.example', DateTime(2026, 10, 20));
    SharedPreferences.setMockInitialValues({
      HistoryService.storageKey: jsonEncode([good.toJson(), {'content': 42}]),
    });

    expect((await HistoryService().getRecords()).map((item) => item.content), [
      'https://valid.example',
    ]);
  });

  test('deduplicates same content inside the repeat window', () async {
    final service = HistoryService();
    final time = DateTime(2026, 10, 20, 12);

    expect(await service.addRecord(record('https://same.example', time)), isTrue);
    expect(
      await service.addRecord(
        record('https://same.example', time.add(const Duration(seconds: 1))),
      ),
      isFalse,
    );
    expect((await service.getRecords()).length, 1);
  });

  test('clear removes QRGuard records but preserves unrelated preferences', () async {
    SharedPreferences.setMockInitialValues({
      HistoryService.storageKey: '[]',
      'other.app.preference': 'keep me',
    });

    await HistoryService().clearHistory();
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.containsKey(HistoryService.storageKey), isFalse);
    expect(preferences.getString('other.app.preference'), 'keep me');
  });
}
