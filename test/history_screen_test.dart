import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrguard/models/scan_record.dart';
import 'package:qrguard/screens/history_screen.dart';
import 'package:qrguard/services/history_service.dart';
import 'package:qrguard/services/url_analyzer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the empty history state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No scans yet'), findsOneWidget);
    expect(find.text('QR codes you analyze will appear here.'), findsOneWidget);
  });

  testWidgets('lists records newest first and opens stored details', (tester) async {
    final service = HistoryService();
    final olderDate = DateTime(2026, 10, 19, 9);
    final newerDate = DateTime(2026, 10, 20, 11);
    await service.addRecord(
      ScanRecord.fromAnalysis(
        analyzeUrl('https://older.example/path'),
        scannedAt: olderDate,
      ),
    );
    await service.addRecord(
      ScanRecord.fromAnalysis(
        analyzeUrl('https://newer.example/path'),
        scannedAt: newerDate,
      ),
    );

    await tester.pumpWidget(MaterialApp(home: HistoryScreen(historyService: service)));
    await tester.pumpAndSettle();

    expect(find.text('2 scans stored on this device'), findsOneWidget);
    final newerPosition = tester.getTopLeft(find.text('https://newer.example/path')).dy;
    final olderPosition = tester.getTopLeft(find.text('https://older.example/path')).dy;
    expect(newerPosition, lessThan(olderPosition));

    await tester.tap(find.text('https://newer.example/path'));
    await tester.pumpAndSettle();
    expect(find.text('URL risk analysis'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('HTTPS connection'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('HTTPS connection'), findsOneWidget);
  });

  testWidgets('searches history by domain', (tester) async {
    final service = HistoryService();
    await service.addRecord(ScanRecord.fromAnalysis(analyzeUrl('https://alpha.example')));
    await service.addRecord(ScanRecord.fromAnalysis(analyzeUrl('https://beta.example')));

    await tester.pumpWidget(MaterialApp(home: HistoryScreen(historyService: service)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('history-search')), 'beta.example');
    await tester.pumpAndSettle();

    expect(find.text('https://beta.example'), findsOneWidget);
    expect(find.text('https://alpha.example'), findsNothing);
  });

  testWidgets('filters history by risk', (tester) async {
    final service = HistoryService();
    await service.addRecord(ScanRecord.fromAnalysis(analyzeUrl('https://safe.example')));
    await service.addRecord(ScanRecord.fromAnalysis(analyzeUrl('http://caution.example')));

    await tester.pumpWidget(MaterialApp(home: HistoryScreen(historyService: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Safe'));
    await tester.pumpAndSettle();

    expect(find.text('https://safe.example'), findsNothing);
    expect(find.text('http://caution.example'), findsOneWidget);
  });

  testWidgets('opens stored URL details without launching the URL', (tester) async {
    final service = HistoryService();
    await service.addRecord(ScanRecord.fromAnalysis(analyzeUrl('https://stored.example')));

    await tester.pumpWidget(MaterialApp(home: HistoryScreen(historyService: service)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('https://stored.example'));
    await tester.pumpAndSettle();

    expect(find.text('Scan Result'), findsOneWidget);
    expect(find.text('Reanalyse URL'), findsOneWidget);
  });

  testWidgets('requires confirmation and then clears stored history', (tester) async {
    final service = HistoryService();
    await service.addRecord(
      ScanRecord.fromAnalysis(analyzeUrl('https://clear.example')),
    );
    await tester.pumpWidget(MaterialApp(home: HistoryScreen(historyService: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Clear scan history'));
    await tester.pumpAndSettle();
    expect(find.text('Clear scan history?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((await service.getRecords()).length, 1);

    await tester.tap(find.byTooltip('Clear scan history'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear history'));
    await tester.pumpAndSettle();

    expect(await service.getRecords(), isEmpty);
    expect(find.text('No scans yet'), findsOneWidget);
  });
}