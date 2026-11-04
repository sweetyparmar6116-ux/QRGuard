# Implementation plan (one-week target)

## Phase 0 — Inspect before editing
- Inspect the existing Flutter starter project.
- Confirm Flutter/Dart versions and current dependencies.
- Read this documentation.
- Do not replace the starter app until the plan is reviewed.

## Phase 1 — App shell
- Establish theme and basic navigation.
- Create the home screen with Scan QR and History actions.
- Confirm the app runs before adding camera functionality.

## Phase 2 — QR scanning
- Add a compatible QR scanner dependency.
- Implement camera permission and scanner UI.
- Decode content and pause/stop scanning after the first result.
- Never open the decoded content automatically.

## Phase 3 — URL analysis
- Implement a pure URL analyzer with structured findings.
- Validate only HTTP/HTTPS links for opening.
- Add documented heuristic rules and unit tests.
- Display the risk level, findings, and limitation note.

## Phase 4 — Result actions
- Add Copy URL.
- Add a confirmation step before launching supported web URLs.
- Do not provide browser launch for unsupported schemes or non-URL QR content.

## Phase 5 — Local history
- Store a bounded history on-device.
- Show records and their results.
- Add clear-history confirmation.
- Handle storage errors and malformed records.

## Phase 6 — Test and polish
- Run formatter, analyzer, and unit tests.
- Test all relevant cases in `TEST_PLAN.md`.
- Verify behavior on a physical Android device.
- Improve layout and error messages without adding scope creep.

## Suggested time allocation
- Day 1: inspect, dependencies, app shell
- Day 2: QR scanning
- Day 3: URL analysis and unit tests
- Day 4: results and safe link opening
- Day 5: history
- Day 6: integration testing and bug fixes
- Day 7: visual polish, final test, demonstration preparation

## Definition of done
The app scans a QR code, displays its contents without auto-opening, explains local URL warnings, requires explicit confirmation before opening a supported link, persists scan history locally, and passes the applicable test cases that were actually executed.
