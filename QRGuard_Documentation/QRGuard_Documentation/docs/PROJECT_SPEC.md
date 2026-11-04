# Project specification

## Project name
QRGuard

## Problem statement
QR codes are used for payments, forms, offers, event registrations, and websites. A user often cannot see the destination URL before scanning. A malicious QR code may lead to a phishing page or other suspicious destination, where a user could be tricked into sharing credentials or personal information.

## Proposed solution
QRGuard lets the user scan a QR code, inspect the decoded contents, analyze supported web URLs for common warning signs, read an explanation of the result, and decide whether to open the link. It also keeps a local history of previous scans.

## Objectives
- Reveal the destination before opening it.
- Identify common URL warning indicators using transparent rules.
- Explain each triggered rule in plain language.
- Keep users in control of opening links.
- Let users revisit and clear their scan history.
- Provide a practical Flutter mobile application suitable for a student demonstration.

## Target users
People who scan QR codes for links, events, offers, or general information and want a simple pre-open safety check.

## Functional requirements
- FR-01: Request camera access when scanning is started.
- FR-02: Scan and decode a QR code.
- FR-03: Do not automatically open decoded contents.
- FR-04: Display the decoded text and, for supported web links, a normalized/parsed host and full URL.
- FR-05: Analyze supported HTTP/HTTPS URLs.
- FR-06: Display a risk level and the individual reasons that contributed to it.
- FR-07: Allow copying the decoded URL.
- FR-08: Offer opening only for validated HTTP/HTTPS links, after explicit user action and an appropriate warning.
- FR-09: Store scan history locally.
- FR-10: Show previous scans and their results.
- FR-11: Allow clearing history.
- FR-12: Handle non-URL QR content and malformed data without crashing.
- FR-13: Handle camera permission denial and scan cancellation gracefully.

## Non-functional requirements
- NFR-01: Clear, readable mobile interface.
- NFR-02: Risk rules must be deterministic and testable.
- NFR-03: First version works without a remote backend.
- NFR-04: History is stored on the device.
- NFR-05: The app must not claim that heuristic checks prove a site is safe.
- NFR-06: Avoid exposing scanned content to external services in the first version.

## Scope

### In scope
Camera scanning, URL parsing, local heuristic checks, explanations, copy/open actions, local history, error states, and Android-device testing.

### Out of scope for first version
- Guaranteed phishing detection
- Automatic crawling of destination websites
- Login/accounts or cloud synchronization
- Paid threat-intelligence API
- QR-code generation
- Payment processing
- Automatic blocking at the Android operating-system level

## Success criteria
- A valid URL QR code can be scanned and displayed without automatically opening it.
- Analysis produces a risk level and understandable reasons.
- A user must choose to open a supported link.
- Non-URL QR codes are handled safely.
- History persists after restarting the app and can be cleared.
- Main test cases in `TEST_PLAN.md` pass on a physical Android phone.
