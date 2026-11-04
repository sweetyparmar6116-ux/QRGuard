import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:madl_project/services/history_service.dart';
import 'package:madl_project/screens/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildSubject(
    String content, {
    required LinkLaunchCallback launch,
  }) {
    return MaterialApp(
      home: ResultScreen(
        decodedContent: content,
        launchUrlOverride: launch,
      ),
    );
  }

  testWidgets('opens a valid low-risk URL only after explicit tap', (tester) async {
    var launchCount = 0;
    Uri? launchedUri;
    await tester.pumpWidget(buildSubject(
      'https://example.com',
      launch: (uri) async {
        launchCount++;
        launchedUri = uri;
        return true;
      },
    ));

    expect(launchCount, 0);
    await tester.tap(find.text('Open website'));
    await tester.pumpAndSettle();

    expect(launchCount, 1);
    expect(launchedUri?.scheme, 'https');
    expect(launchedUri?.host, 'example.com');
  });

  testWidgets('saves completed analysis to local history without opening it',
      (tester) async {
    var launchCount = 0;
    final service = HistoryService();
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          decodedContent: 'https://saved.example',
          historyService: service,
          launchUrlOverride: (_) async {
            launchCount++;
            return true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final records = await service.getRecords();
    expect(records.single.content, 'https://saved.example');
    expect(launchCount, 0);
  });

  testWidgets('does not allow unsupported schemes to reach launcher', (tester) async {
    var launchCount = 0;
    await tester.pumpWidget(buildSubject(
      'javascript:alert(1)',
      launch: (_) async {
        launchCount++;
        return true;
      },
    ));

    expect(find.text('QR code contains non-URL content'), findsOneWidget);
    expect(find.text('Copy decoded content'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Copy decoded content'),
      ).onPressed,
      isNotNull,
    );
    expect(launchCount, 0);
  });

  testWidgets('cancelling a caution warning does not launch the URL', (tester) async {
    var launchCount = 0;
    await tester.pumpWidget(buildSubject(
      'http://example.com',
      launch: (_) async {
        launchCount++;
        return true;
      },
    ));

    await tester.tap(find.text('Open website'));
    await tester.pumpAndSettle();
    expect(find.text('Review this link'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(launchCount, 0);
    expect(find.text('Review this link'), findsNothing);
  });

  testWidgets('reports launch failures', (tester) async {
    await tester.pumpWidget(buildSubject(
      'https://example.com',
      launch: (_) async => false,
    ));

    await tester.tap(find.text('Open website'));
    await tester.pumpAndSettle();

    expect(find.text('Could not open this website. Please try again.'), findsOneWidget);
  });
}
