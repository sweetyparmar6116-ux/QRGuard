# User flows and screen plan

## Navigation
Use a simple home screen with clear actions to **Scan QR** and **Scan History**. Avoid unnecessary sign-in, onboarding, or settings screens in the first version.

## Screen 1: Home
- QRGuard name and short tagline: “Scan smart. Check first. Open safely.”
- Primary Scan QR action
- Recent scan preview, if history exists
- History action
- Clear empty state for first-time users

## Screen 2: Scanner
- Live camera preview with scan frame
- Short instruction: “Point your camera at a QR code”
- Camera permission explanation and recovery path if denied
- Pause scanning after a result is detected to avoid duplicate results
- No automatic navigation to the decoded destination

## Screen 3: Scan result and analysis
Show:
- Risk level: Safe, Caution, or High Risk
- Full decoded URL/text
- Hostname clearly separated from the rest of the URL when parsing succeeds
- List of triggered warning rules and plain-language explanations
- A limitation note: “This is a heuristic check, not a guarantee that the site is safe.”
- Copy URL action
- Open Link action only for validated HTTP/HTTPS links
- A confirmation/warning step before opening, especially for Caution or High Risk
- Back/home action

If QR content is not an HTTP/HTTPS URL, show it as text and do not provide a browser-open action by default.

## Screen 4: History
Each record can include:
- Decoded URL or a safely truncated display string
- Risk level
- Scan timestamp
- Tap to reopen the result details within QRGuard
- Clear history action with confirmation

History should remain on-device. Consider a reasonable maximum number of records to prevent unbounded storage growth.

## Visual design
- Modern, calm security-oriented interface
- Strong contrast and accessible text sizes
- Use text labels alongside colors; never communicate risk using color alone
- Suggested palette: dark navy/charcoal, off-white surfaces, teal accent, amber for caution, red for high risk, green for “no configured indicators detected”
- Keep screens simple enough for a one-week student project

## Key interaction rule
A scan result is a review step, not a redirect. The app must not launch a browser as a side effect of decoding a QR code.
