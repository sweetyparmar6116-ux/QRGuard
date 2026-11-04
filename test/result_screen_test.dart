import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrguard/services/history_service.dart';
import 'package:qrguard/screens/result_screen.dart';
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

    expect(find.text('QR code details'), findsOneWidget);
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

  testWidgets('shows UPI payment details without opening the payment app', (tester) async {
    var launchCount = 0;
    await tester.pumpWidget(buildSubject(
      'upi://pay?pa=shop%40okaxis&pn=Corner%20Store&am=125.50&cu=INR',
      launch: (_) async {
        launchCount++;
        return true;
      },
    ));
    await tester.pumpAndSettle();

    expect(find.text('Payment QR code'), findsOneWidget);
    expect(find.text('PAYMENT QR · CHECK DETAILS'), findsOneWidget);
    expect(find.text('Payee: Corner Store'), findsOneWidget);
    expect(find.text('UPI ID: shop@okaxis'), findsOneWidget);
    expect(find.text('Amount: INR 125.50'), findsOneWidget);
    expect(find.text('Continue to payment app'), findsOneWidget);
    expect(launchCount, 0);
  });

}
