# Technical design

## Proposed architecture
Keep business logic independent of widgets.

```text
lib/
  main.dart
  app.dart                  # App setup and theme (if useful)
  models/
    scan_record.dart        # Stored scan data and serialization
    analysis_result.dart    # Risk level and findings
  services/
    qr_scan_service.dart    # Scanner integration, if separated
    url_analyzer.dart       # Pure URL/risk analysis logic
    history_service.dart    # Local persistence
  screens/
    home_screen.dart
    scanner_screen.dart
    result_screen.dart
    history_screen.dart
  widgets/
    risk_badge.dart
    finding_tile.dart
```

This is a suggested structure, not a requirement to split every small widget into its own file. Keep the project understandable and avoid overengineering.

## Packages to evaluate
- `mobile_scanner`: camera-based QR/barcode scanning.
- `shared_preferences`: small local key-value storage for a modest history.
- `url_launcher`: open validated web URLs after user confirmation.

Check package compatibility and current APIs before implementation. Do not add packages that are not needed.

## Data model (suggested)
`ScanRecord`
- `id`: unique local identifier
- `rawContent`: decoded QR text
- `scannedAt`: ISO-8601 timestamp
- `riskLevel`: `safe`, `caution`, `highRisk`, or `notApplicable`
- `findings`: list of rule identifiers or short explanations

`AnalysisResult`
- `riskLevel`
- `findings`: list of structured findings
- `isSupportedWebUrl`
- `parsedHost` (when available)
- `summary`

## Analysis boundary
Use a pure function such as `analyzeUrl(String input) -> AnalysisResult`. It should not open links, access the network, write history, or depend on UI state. This makes it straightforward to unit test.

## URL parsing and opening
- Parse with Dart's `Uri` APIs.
- Support only `http` and `https` for browser opening.
- Require a non-empty valid host.
- Treat decoded QR content as untrusted.
- Do not use string-prefix checks alone to determine a trusted host.
- Do not auto-follow shortened URLs in the first version.
- Avoid fetching or previewing remote pages in the first version.
- Show the actual hostname from the parsed URI, not a guessed label.

## Local history
Serialize a bounded list of scan records to local storage. Handle malformed stored data and storage errors gracefully. Include a clear-history action. `shared_preferences` is suitable for a small demonstration history; a database can be considered later only if necessary.

## Android setup
Check whether camera permission is declared by the chosen scanner package and whether any additional manifest change is required by its current documentation. Explain permission usage in the UI. Do not add unrelated permissions.

## Quality checks
Run:
```powershell
dart format .
flutter analyze
flutter test
```
Run tests that exist; do not report passing tests if they were not run.
