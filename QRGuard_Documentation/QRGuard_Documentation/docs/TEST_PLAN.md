# Test plan

## Manual tests on a physical Android phone

| ID | Scenario | Expected result |
|---|---|---|
| T-01 | Scan QR containing a valid HTTPS URL | URL appears; browser does not open automatically |
| T-02 | Scan QR containing an HTTP URL | Caution warning explains HTTP transport limitation |
| T-03 | Scan QR containing a URL with an IP host | A relevant finding appears, without claiming certainty |
| T-04 | Scan QR containing a known shortener domain | Shortener warning appears; destination is not fetched automatically |
| T-05 | Scan a normal HTTPS URL with no configured indicators | “Safe” or “no configured indicators” result with explicit limitation note |
| T-06 | Scan plain text | Text is displayed; no browser action is offered |
| T-07 | Scan malformed URL | Safe error/result state; app does not crash or open it |
| T-08 | Deny camera permission | Helpful message and recovery path appear |
| T-09 | Scan the same QR repeatedly | No uncontrolled duplicate navigation or duplicate records |
| T-10 | Copy a URL | Correct decoded URL is copied |
| T-11 | Tap Open Link for a supported URL | Confirmation occurs first, then browser is launched only after user action |
| T-12 | Try unsupported scheme such as `javascript:` or `file:` | No browser-open action is offered |
| T-13 | Restart app after scans | History remains available |
| T-14 | Clear history | Confirmation appears and records are removed |
| T-15 | Stored history contains malformed data | App recovers gracefully rather than crashing |

Use harmless test QR codes that you create yourself. Do not test by opening real suspected phishing links.

## Unit tests for URL analyzer
Cover:
- valid HTTP and HTTPS URLs
- invalid/malformed URLs
- empty input
- IP-address hosts
- known shortener hosts and non-shortener lookalikes
- user-info and deceptive host patterns
- suspicious terms as weak signals
- multiple rules and risk thresholds
- normal URLs that should not be over-flagged
- unsupported schemes

## Regression checks after implementation
Run:
```powershell
dart format .
flutter analyze
flutter test
```
Also launch the app and verify camera scanning on the physical device.

## Reporting
Record which tests were actually run and their outcomes. Do not mark tests passed based only on code review.
