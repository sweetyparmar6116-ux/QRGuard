# URL risk analysis

## Purpose
QRGuard uses explainable local heuristics to identify warning indicators. It does not establish whether a website is genuinely malicious and does not replace a threat-intelligence service.

## Output levels
- **Safe**: No configured warning rules were triggered. This does not prove the URL is safe.
- **Caution**: One or more moderate warning indicators were triggered.
- **High Risk**: Multiple strong warning indicators or a deliberately deceptive URL pattern were detected.
- **Not applicable**: QR content is not a supported HTTP/HTTPS URL, so URL risk rules are not applied.

Keep thresholds explicit and unit tested. Avoid implying the scoring scheme is scientifically validated.

## Candidate checks
1. **Scheme**: HTTP is unencrypted in transit and should trigger a warning. HTTPS is a positive transport-security signal only; it is not proof of legitimacy.
2. **IP-based host**: A numeric IP host instead of a domain name can be suspicious in some contexts, but is not automatically malicious.
3. **Known URL shortener**: Compare the parsed hostname against a small, documented list of common shortening services. Shorteners hide the final destination; they are not necessarily malicious. Do not fetch the destination automatically.
4. **Potentially deceptive host**: Inspect parsed hostname labels, including lookalike patterns and misleading subdomains. Explain the exact detected pattern; avoid simplistic rules that flag every occurrence of a brand word.
5. **Unusual characters and user-info**: Flag relevant URL structures such as user-info (`user@host`) or confusing encoded/Unicode hostname forms where appropriate. Parse the URL first; do not rely on raw substring matching alone.
6. **Suspicious terms**: Treat words like `verify`, `account`, or `login` as weak contextual signals only. These terms are common on legitimate sites and should not alone cause a High Risk result.
7. **Malformed or unsupported URL**: Do not open it. Explain that the content could not be safely treated as a supported web link.

## Explainability
Each finding should include:
- A short title
- What was detected
- Why it matters
- A practical next step

Example:
- Title: “URL shortener detected”
- Explanation: “This address uses a shortening service, so the final destination is not visible here.”
- Advice: “Only continue if you trust the source. QRGuard has not verified the final destination.”

## Suggested initial scoring approach
Prefer a small number of clearly documented rule weights over opaque scoring. Example starting point:
- HTTP: moderate warning
- Known URL shortener: moderate warning
- IP-based hostname: moderate warning
- Explicitly deceptive hostname/user-info pattern: stronger warning
- Multiple independent warnings: may elevate to High Risk

Choose exact weights and thresholds during implementation and add unit tests for every rule and combination. Do not claim the values are validated against real-world phishing data.

## Safety requirements
- Never automatically open a URL after scan.
- Never claim that HTTPS means safe.
- Never claim “Safe” means verified clean.
- Do not expand short URLs by network request in the first version.
- Do not send scanned URLs to third parties in the first version.
- Make it easy for the user to copy a URL for independent checking.
