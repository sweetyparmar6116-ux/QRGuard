# QRGuard Demo Guide

## Run the app

From the project root:

```powershell
flutter pub get
flutter run
```

For a debug APK:

```powershell
flutter build apk --debug
```

The expected APK path is `build/app/outputs/flutter-apk/app-debug.apk`.

## Scan a QR code

1. Use a physical Android phone and allow camera access when prompted.
2. Display a QR code on another screen or print it, then tap **Scan QR Code** in QRGuard.
3. Center the code in the scanner frame. The decoded content should appear on the result screen; scanning never opens a website automatically.
4. Use **Return to scanning** to scan again. Use the flashlight control if the phone supports it.

Suggested QR contents (encode each exact string as a QR code):

- Low Risk example: `https://example.com/`
- Caution example: `http://example.com/`
- Caution shortener example: `https://bit.ly/demo`
- Caution wording example: `https://example.com/urgent-action-account-verification`
- High Risk rule example: `https://paypal.attacker.test/login`
- High Risk user-info example: `https://example.com@attacker.test/login`
- Non-URL example: `QRGuard classroom demo text`
- Unsupported scheme example: `javascript:alert(1)`

The `attacker.test` examples are inert demonstration strings using the reserved `.test` domain. Do not open them. For a caution or high-risk result, demonstrate the warning and choose **Cancel**. If demonstrating **Open anyway**, use only a URL you independently trust and expect to visit.

## Demonstrate history

1. Scan one or more contents and let the result screen appear. Each analyzed result is saved locally.
2. Return to home and show **Recent Scans**, or open **Scan History** to see all records newest-first.
3. Tap a record to view its stored classification and findings.
4. Use **Clear scan history**, then confirm in the dialog. Cancel once to demonstrate that deletion can be prevented.
5. Restart the app and open history to check persistence on the device.

## What the labels mean

QRGuard uses local, rule-based indicators. Low Risk means no configured warning rule triggered; it does not guarantee safety. Caution or High Risk describes detected signals and does not prove malicious intent. A result is not a substitute for independently checking a destination.

## Limitations and manual checks

- Camera permission, live QR decoding, flashlight behavior, browser handoff, and persistence across process/device restarts require a physical Android device for demonstration.
- Scanner and launch behavior can vary by Android version and installed browser apps.
- URL analysis is heuristic and offline. It does not follow redirects, inspect page content, or query a threat-intelligence service.
- The high-risk demo hosts are examples for triggering local rules and should be cancelled rather than opened.
- These scenarios are suggested test inputs; their camera behavior has not been verified on a physical device as part of this guide's preparation.
