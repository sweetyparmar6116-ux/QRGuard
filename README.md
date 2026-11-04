# QRGuard

**Scan smart. Check first. Open safely.**

QRGuard is a Flutter app that reads QR codes, explains what they contain, and gives users a chance to review links before opening them.

## Features
- Scan QR codes with the phone camera.
- Select an image from the gallery and scan a QR code from it.
- Recognise website links, UPI payment QR codes, Wi-Fi details, contacts, phone numbers, SMS, email addresses and plain text.
- Check website links with local, rule-based warning indicators.
- Show UPI payee, UPI ID and requested amount in a separate blue **Payment QR · Check details** view.
- Ask for confirmation before opening a payment app or a website with warning signals.
- Keep scan history locally on the device.
- Copy decoded QR content when no external action is needed.

## Important safety notes
- A green/low-warning website result is **not a guarantee** that a website is safe.
- QRGuard's URL checks are local heuristics. They do not query a live threat-intelligence service or verify website ownership.
- QRGuard cannot verify the identity of a UPI recipient. Always confirm the payee and amount in your payment app before approving a payment.
- Never enter your UPI PIN to receive money.
- QRGuard does not make payments or open scanned links automatically.

## Tech stack
- Flutter and Dart
- `mobile_scanner` for camera and image QR scanning
- `image_picker` for gallery selection
- `shared_preferences` for local scan history
- `url_launcher` for user-confirmed external actions

## Run locally
Install Flutter, then run these commands from the project directory:
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

To build an Android APK:
```bash
flutter build apk --release
```

The Android application ID is `com.qrguard.app`.

## Privacy
Scan history is stored locally using SharedPreferences. QR contents are not sent to a QRGuard backend because this project does not use a backend service.