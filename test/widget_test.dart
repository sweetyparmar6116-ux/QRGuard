import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrguard/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home screen fits a compact phone viewport', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const QRGuardApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Scan QR Code'), findsOneWidget);
    expect(find.text('No scans yet'), findsOneWidget);
  });

  testWidgets('home navigation opens the scan history screen', (tester) async {
    await tester.pumpWidget(const QRGuardApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scan History'));
    await tester.pumpAndSettle();

    expect(find.text('Scan History'), findsOneWidget);
    expect(find.text('No scans yet'), findsOneWidget);
  });

  testWidgets('manual URL analysis validates empty input', (tester) async {
    await tester.pumpWidget(const QRGuardApp());
    await tester.tap(find.text('Analyze URL Manually'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('manual-analyze-button')));
    await tester.pump();

    expect(find.text('Enter a URL to analyze.'), findsOneWidget);
    expect(find.text('Scan Result'), findsNothing);
  });

  testWidgets('manual URL analysis rejects invalid URLs', (tester) async {
    await tester.pumpWidget(const QRGuardApp());
    await tester.tap(find.text('Analyze URL Manually'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'ftp://example.com');
    await tester.tap(find.byKey(const Key('manual-analyze-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('manual-url-error')), findsOneWidget);
    expect(find.text('Scan Result'), findsNothing);
  });

  testWidgets('manual URL analysis opens the result screen for valid URLs', (tester) async {
    await tester.pumpWidget(const QRGuardApp());
    await tester.tap(find.text('Analyze URL Manually'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'https://example.com');
    await tester.tap(find.byKey(const Key('manual-analyze-button')));
    await tester.pumpAndSettle();

    expect(find.text('Scan Result'), findsOneWidget);
    expect(find.text('Website link'), findsOneWidget);
  });
}



