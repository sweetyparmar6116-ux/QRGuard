# QRGuard — Instructions for AI coding agents

Read `README.md` and every relevant file in `docs/` before making changes.

## Working rules

1. Inspect the existing Flutter project before editing. Preserve its current structure and working configuration.
2. Do not create a second Flutter project or overwrite files unrelated to QRGuard.
3. Implement incrementally. After each feature, run formatting and relevant checks, then report exactly what ran and what passed or failed.
4. Do not claim a feature is complete or tested unless it was actually implemented and tested.
5. Keep the first version local/offline for URL analysis and scan history. Do not add a backend, accounts, analytics, or paid API.
6. Never automatically open a URL decoded from a QR code.
7. Treat QR contents as untrusted input. Parse and validate before offering link-opening actions.
8. Only offer browser opening for explicitly supported `http` and `https` URLs with a valid host. Do not automatically open `javascript:`, `file:`, `intent:`, or other schemes.
9. Make the risk explanation visible. Do not label a URL “guaranteed safe.”
10. Keep risk logic separate from UI code so it can be unit tested.
11. Handle camera permission denial, invalid QR contents, malformed URLs, storage failures, and repeated scan callbacks gracefully.
12. Do not store more QR data than needed. History should remain on-device and have a clear-history action.
13. Use packages compatible with the installed Flutter/Dart SDK. Explain any dependency choice.
14. Maintain readable Dart code, meaningful names, and small widgets/files where appropriate.
15. Before major edits, explain the planned files and changes. Ask before deleting or replacing user work.

## Desired first response

Inspect the repository and report:
- the existing app structure,
- current Flutter/Dart versions if available,
- files that would be added or modified,
- any setup issues.

Do not modify files in the first inspection. Then propose a small implementation sequence based on `docs/IMPLEMENTATION_PLAN.md`.
