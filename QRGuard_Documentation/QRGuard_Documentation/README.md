# QRGuard

**Scan smart. Check first. Open safely.**

QRGuard is a Flutter-based Android application that helps users inspect the destination encoded in a QR code before choosing whether to open it. It performs transparent, rule-based URL checks, explains detected warning signs, and stores a local scan history.

## Project status

- [ ] Confirm requirements and UI plan
- [ ] Implement QR scanning
- [ ] Implement URL analysis and risk explanations
- [ ] Implement safe link-opening flow
- [ ] Implement local scan history
- [ ] Test on Android device
- [ ] Prepare demonstration and viva explanation

## Core features

1. Scan QR codes using the device camera.
2. Decode and display QR contents without automatically opening a destination.
3. Analyze HTTP/HTTPS URLs for suspicious characteristics.
4. Show **Safe**, **Caution**, or **High Risk**, with reasons.
5. Let users copy a URL or explicitly choose to open it after reviewing a warning.
6. Keep scan history locally on the device.

## Important security limitation

QRGuard's local rules are heuristics, not a definitive phishing detector. HTTPS does not mean a site is trustworthy, and a URL with no detected warning signs is not guaranteed safe. Do not describe the app as detecting all phishing sites. Online reputation checking is out of scope for the first version.

## Planned technology

- Flutter and Dart
- `mobile_scanner` for QR scanning
- `shared_preferences` for small local history storage
- `url_launcher` for opening a link only after user action

Check current package compatibility before adding dependencies. No backend or paid API is required for the initial version.

## Documentation

- [Problem statement and scope](docs/PROJECT_SPEC.md)
- [User flows and screens](docs/USER_FLOWS.md)
- [Architecture and data model](docs/TECHNICAL_DESIGN.md)
- [URL risk rules](docs/RISK_ANALYSIS.md)
- [Test plan](docs/TEST_PLAN.md)
- [Implementation checklist](docs/IMPLEMENTATION_PLAN.md)
- [Instructions for Antigravity](AGENTS.md)

## Run locally

From the project root:

```powershell
flutter pub get
flutter doctor
flutter run
```

Use `flutter devices` to see available targets. Android camera scanning should be tested on a physical device.

## Privacy principles

- Do not upload scanned URLs anywhere in the first version.
- Store history locally.
- Do not automatically navigate to scanned links.
- Provide a way to clear history.
- Avoid logging sensitive QR contents unnecessarily.
