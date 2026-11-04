import '../models/analysis_result.dart';

const Set<String> knownUrlShorteners = {
	'bit.ly',
	'bitly.com',
	'tinyurl.com',
	't.co',
	'goo.gl',
	'ow.ly',
	'is.gd',
	'buff.ly',
	'shorturl.at',
	'rebrand.ly',
	'cutt.ly',
	'rb.gy',
	'lnkd.in',
};

const Map<String, String> _brandDomains = {
	'amazon': 'amazon.com',
	'apple': 'apple.com',
	'facebook': 'facebook.com',
	'google': 'google.com',
	'instagram': 'instagram.com',
	'microsoft': 'microsoft.com',
	'paypal': 'paypal.com',
};

const List<String> _deceptivePhrases = [
	'account verification',
	'verify your account',
	'verify-account',
	'password reset',
	'reset your password',
	'urgent action',
	'act immediately',
	'prize claim',
	'claim your prize',
	'claim your reward',
	'you have won',
	'unusual login',
	'confirm your login',
];

/// Analyzes an HTTP(S) URL using local, explainable heuristics only.
AnalysisResult analyzeUrl(String input) {
  final value = input.trim();
  if (value.isEmpty) return _invalid(value, 'The QR code did not contain a URL.');

  final uri = Uri.tryParse(value);
  if (uri == null ||
      (uri.scheme.toLowerCase() != 'http' && uri.scheme.toLowerCase() != 'https') ||
      uri.host.isEmpty ||
      value.contains(RegExp(r'\s'))) {
    return _invalid(
      value,
      'This content is not a valid HTTP or HTTPS URL, so it was not analyzed as a website.',
    );
  }
  if (!_hasValidAuthority(uri)) {
    return _invalid(
      value,
      'This URL has an invalid hostname or port and was not analyzed as a website.',
    );
  }

  final findings = <Finding>[];
  final warningCategories = <String>{};
  final strongCategories = <String>{};
  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase().replaceFirst(RegExp(r'\.$'), '');
  final content = '$host ${uri.path} ${uri.query} ${uri.fragment}'
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ');

  findings.add(Finding(
    title: scheme == 'https' ? 'HTTPS connection' : 'Unencrypted HTTP',
    description: scheme == 'https'
        ? 'HTTPS encrypts data in transit, but it does not guarantee the website itself is trustworthy or verify the website owner. Confirm the domain before proceeding.'
        : 'HTTP does not encrypt the connection. Avoid entering passwords, payment details or other sensitive information. Confirm the displayed hostname before opening it.',
    isWarning: scheme == 'http',
  ));
  if (scheme == 'http') warningCategories.add('transport');

  if (_isIpAddress(host)) {
    findings.add(const Finding(
      title: 'IP-based host',
      description: 'The hostname is a numeric IP address rather than a registered domain. This can hide the owner or route to unexpected infrastructure. Verify the destination independently.',
    ));
    warningCategories.add('ip-host');
  }

  if (knownUrlShorteners.contains(host)) {
    findings.add(const Finding(
      title: 'URL shortener',
      description: 'This known shortening service hides the final destination behind a short link. QRGuard cannot verify the redirect target locally; confirm the destination with a trusted redirect viewer before proceeding.',
    ));
    warningCategories.add('shortener');
  }

  if (_deceptivePhrases.any((phrase) =>
      content.contains(phrase.replaceAll(RegExp(r'[^a-z0-9]+'), ' ')))) {
    findings.add(const Finding(
      title: 'Potentially deceptive wording',
      description: 'The URL contains urgency or account-action wording commonly used in phishing links. It is a warning signal, not proof of malicious intent; verify the page independently.',
    ));
    warningCategories.add('wording');
  }

  final usesUserInfo = uri.userInfo.isNotEmpty;
  final suspiciousBrand = _hasMisleadingBrandHost(host);
  final manySubdomains = host.split('.').length >= 5;
  final punycode = host.split('.').any((label) => label.startsWith('xn--'));
  final authorityDetails = <String>[];
  if (usesUserInfo) {
    authorityDetails.add('the authority contains user-info before the @ symbol');
  }
  if (suspiciousBrand) {
    authorityDetails.add('a familiar brand name appears outside that brand’s registered domain');
  }
  if (manySubdomains) {
    authorityDetails.add('the hostname has an unusually deep subdomain structure');
  }
  if (punycode) {
    authorityDetails.add('the hostname uses Punycode');
  }
  if (authorityDetails.isNotEmpty) {
    findings.add(Finding(
      title: 'Deceptive or unusual URL structure',
      description: 'Review the hostname carefully: ${authorityDetails.join('; ')}. These techniques can disguise the real destination; verify the exact domain before opening it.',
    ));
    warningCategories.add('structure');
    if (usesUserInfo || suspiciousBrand || punycode) strongCategories.add('structure');
  }

  final nonAscii = value.codeUnits.any((unit) => unit > 127);
  if (nonAscii || host.contains('xn--')) {
    findings.add(const Finding(
      title: 'Unicode or international hostname',
      description: 'This URL contains non-ASCII characters or an internationalized-domain encoding. Compare every character carefully because confusable letters can imitate trusted domains. Use the browser’s displayed domain if available.',
    ));
    warningCategories.add('unicode');
    if (_containsConfusableCharacter(value)) strongCategories.add('unicode-confusable');
  }

  final percentSequences = RegExp(r'%[0-9a-fA-F]{2}').allMatches(value).length;
  final excessivePercent = percentSequences >= 4;
  final encodedControl = RegExp(r'%(?:00|09|0[aA]|0[dD])').hasMatch(value);
  if (percentSequences > 0) {
    findings.add(Finding(
      title: encodedControl ? 'Suspicious encoded characters' : 'Encoded URL characters',
      description: encodedControl
          ? 'The URL contains encoded control characters or escapes. These may be used to disguise its destination or break security checks; inspect it carefully and avoid opening it unless verified.'
          : 'The URL contains encoded characters. Excessive encoding can obscure hidden text or redirect targets. Decode it only locally or with a trusted inspection tool.',
    ));
    warningCategories.add('encoding');
    if (excessivePercent || encodedControl) strongCategories.add('encoding');
  }

  final formattingIssues = _misleadingFormatting(value);
  if (formattingIssues.isNotEmpty) {
    findings.add(Finding(
      title: 'Misleading URL formatting',
      description: '${formattingIssues.join('; ')}. Review the authority and destination separately before proceeding.',
    ));
    warningCategories.add('formatting');
  }

  final specialCount = RegExp(r'[^A-Za-z0-9:/._?=&%+#@~-]').allMatches(value).length;
  if (specialCount >= 5) {
    findings.add(Finding(
      title: 'Excessive special characters',
      description: 'The URL contains $specialCount unusual characters in places that may be used to obscure the destination. Compare the hostname with the intended service and avoid opening it if the link cannot be verified.',
    ));
    warningCategories.add('special-chars');
  }

  final suspiciousPort = uri.hasPort && uri.port != 80 && uri.port != 443;
  if (suspiciousPort) {
    findings.add(Finding(
      title: 'Unusual URL port',
      description: 'The link explicitly uses port ${uri.port}, instead of the standard web ports 80 or 443. Confirm why the service is using this port before proceeding.',
    ));
    warningCategories.add('port');
  }

  final warningCount = warningCategories.length;
  final highRisk = strongCategories.isNotEmpty || warningCount >= 3;
  final riskLevel = highRisk
      ? RiskLevel.high
      : warningCount > 0
          ? RiskLevel.medium
          : RiskLevel.low;
  final summary = switch (riskLevel) {
    RiskLevel.low => 'No configured warning rules were triggered. This does not guarantee the website is safe or reputable.',
    RiskLevel.medium => 'One or two warning signals need attention. These local checks cannot confirm whether a website is malicious.',
    RiskLevel.high => 'Strong or multiple warning signals were detected. Verify the exact destination independently and avoid entering sensitive information.',
  };

  return AnalysisResult(
    input: value,
    isValidUrl: true,
    riskLevel: riskLevel,
    summary: summary,
    findings: List.unmodifiable(findings),
  );
}

bool _containsConfusableCharacter(String value) {
  const confusables = {
    'а', 'е', 'о', 'р', 'с', 'у', 'х', 'і', 'ј', 'ѕ', 'ӏ', 'ԁ',
    'Α', 'Β', 'Ε', 'Η', 'Ι', 'Κ', 'Μ', 'Ν', 'Ο', 'Ρ', 'Τ', 'Χ', 'Υ',
  };
  return value.runes.any((rune) => confusables.contains(String.fromCharCode(rune)));
}

List<String> _misleadingFormatting(String value) {
  final issues = <String>[];
  final authority = RegExp(r'^https?://([^/?#]+)', caseSensitive: false)
      .firstMatch(value)
      ?.group(1);
  if (authority != null && authority.contains('@')) {
    issues.add('the authority uses @, which browsers interpret after any user-info text rather than as part of the visible hostname');
  }
  if (authority != null && authority.contains('\uFF20')) {
    issues.add('the authority uses a full-width or visually similar @ character');
  }
  if (RegExp(r'https?:/[^/]', caseSensitive: false).hasMatch(value)) {
    issues.add('the scheme or slash formatting is irregular');
  }
  if (value.contains('%40') || value.toLowerCase().contains('%2f%2f')) {
    issues.add('encoded characters appear where authority or path delimiters are normally expected');
  }
  return issues;
}

AnalysisResult _invalid(String input, String message) => AnalysisResult(
			input: input,
			isValidUrl: false,
			riskLevel: RiskLevel.medium,
			summary: message,
			findings: [
				Finding(
					title: 'Not analyzed as a website',
					description: message,
				),
			],
		);

bool _isIpAddress(String host) {
	final ipv4Parts = host.split('.');
	if (ipv4Parts.length == 4 &&
			ipv4Parts.every((part) =>
					part.isNotEmpty &&
					int.tryParse(part) != null &&
					int.parse(part) >= 0 &&
					int.parse(part) <= 255)) {
		return true;
	}

	final unwrapped = host.startsWith('[') && host.endsWith(']')
			? host.substring(1, host.length - 1)
			: host;
	return unwrapped.contains(':') &&
			RegExp(r'^[0-9a-f:]+$', caseSensitive: false).hasMatch(unwrapped);
}

bool _hasValidAuthority(Uri uri) {
	try {
		if (uri.hasPort && (uri.port < 1 || uri.port > 65535)) return false;
	} on FormatException {
		return false;
	}

	final host = uri.host;
	if (host.startsWith('[') && host.endsWith(']')) {
		return _isIpAddress(host);
	}
	if (host.startsWith('.') || host.endsWith('.') || host.contains('..')) {
		return false;
	}
	return host.split('.').every((label) {
    if (label.isEmpty || label.startsWith('-') || label.endsWith('-')) return false;
    final normalized = label.replaceAll(RegExp(r'%[0-9a-fA-F]{2}'), 'x');
    return normalized.runes.every((rune) =>
        (rune >= 0x30 && rune <= 0x39) ||
        (rune >= 0x61 && rune <= 0x7A) ||
        (rune >= 0x41 && rune <= 0x5A) || rune == 0x2D || rune == 0x78);
  });
}

bool _hasMisleadingBrandHost(String host) {
	for (final entry in _brandDomains.entries) {
		final labels = host.split('.');
		if (labels.contains(entry.key) &&
				host != entry.value &&
				!host.endsWith('.${entry.value}')) {
			return true;
		}
	}
	return false;
}
