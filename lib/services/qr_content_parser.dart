import '../models/qr_content.dart';

QrContent parseQrContent(String input) {
  final value = input.trim();
  if (value.isEmpty) {
    return const QrContent(
      type: QrContentType.unsupported,
      displayLabel: 'Unsupported content',
      decodedContent: '',
    );
  }

  final uri = Uri.tryParse(value);

  // UPI payment payloads must be identified before generic URI handling.
  if (uri != null && uri.scheme.toLowerCase() == 'upi' &&
      uri.host.toLowerCase() == 'pay') {
    final upiId = uri.queryParameters['pa']?.trim();
    final payee = uri.queryParameters['pn']?.trim();
    final amount = uri.queryParameters['am']?.trim();
    final currency = uri.queryParameters['cu']?.trim();
    if (upiId != null && upiId.isNotEmpty && upiId.contains('@')) {
      return QrContent(
        type: QrContentType.payment,
        displayLabel: 'Payment QR',
        decodedContent: value,
        uri: uri,
        payeeName: (payee?.isNotEmpty ?? false) ? payee : null,
        upiId: upiId,
        amount: (amount?.isNotEmpty ?? false) ? amount : null,
        currency: (currency?.isNotEmpty ?? false) ? currency : 'INR',
      );
    }
  }

  if (uri != null &&
      (uri.scheme.toLowerCase() == 'http' || uri.scheme.toLowerCase() == 'https') &&
      uri.host.isNotEmpty) {
    return QrContent(
      type: QrContentType.url,
      displayLabel: 'Website link',
      decodedContent: value,
      uri: uri,
    );
  }

  if (RegExp(r'^WIFI:', caseSensitive: false).hasMatch(value)) {
    final fields = _parseWifi(value);
    if (fields['S']?.trim().isNotEmpty == true) {
      return QrContent(
        type: QrContentType.wifi,
        displayLabel: 'Wi-Fi network',
        decodedContent: value,
        ssid: fields['S'],
        password: fields['P'],
      );
    }
  }

  if (RegExp(r'^BEGIN:VCARD', caseSensitive: false).hasMatch(value) &&
      RegExp(r'^END:VCARD', caseSensitive: false, multiLine: true).hasMatch(value)) {
    final name = _vCardField(value, 'FN') ?? _vCardField(value, 'N');
    return QrContent(
      type: QrContentType.contact,
      displayLabel: 'Contact card',
      decodedContent: value,
      contactName: name?.replaceAll(';', ' ').trim(),
    );
  }

  final smsMatch = RegExp(r'^SMSTO:([^:]+)(?::(.*))?$', caseSensitive: false, dotAll: true)
      .firstMatch(value);
  if (smsMatch != null) {
    final destination = smsMatch.group(1)!.trim();
    if (destination.isNotEmpty) {
      return QrContent(
        type: QrContentType.sms,
        displayLabel: 'SMS message',
        decodedContent: value,
        phoneNumber: destination,
        smsBody: smsMatch.group(2),
      );
    }
  }

  final mailtoMatch = RegExp(r'^mailto:([^?]+)(?:\?(.*))?$', caseSensitive: false, dotAll: true)
      .firstMatch(value);
  if (mailtoMatch != null && _isEmail(mailtoMatch.group(1)!)) {
    return QrContent(
      type: QrContentType.email,
      displayLabel: 'Email address',
      decodedContent: value,
      emailAddress: mailtoMatch.group(1)!.trim(),
    );
  }

  if (_isEmail(value)) {
    return QrContent(
      type: QrContentType.email,
      displayLabel: 'Email address',
      decodedContent: value,
      emailAddress: value,
    );
  }

  final telMatch = RegExp(r'^tel:(.+)$', caseSensitive: false).firstMatch(value);
  if (telMatch != null && _isPhone(telMatch.group(1)!)) {
    return QrContent(
      type: QrContentType.phone,
      displayLabel: 'Phone number',
      decodedContent: value,
      phoneNumber: telMatch.group(1)!.trim(),
    );
  }

  if (_isPhone(value)) {
    return QrContent(
      type: QrContentType.phone,
      displayLabel: 'Phone number',
      decodedContent: value,
      phoneNumber: value,
    );
  }

  if (_looksLikeUri(value, uri)) {
    return QrContent(
      type: QrContentType.unsupported,
      displayLabel: 'Unsupported content',
      decodedContent: value,
      uri: uri,
    );
  }

  return QrContent(
    type: QrContentType.text,
    displayLabel: 'Plain text',
    decodedContent: value,
  );
}

bool _isEmail(String value) =>
    RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$").hasMatch(value.trim());

bool _isPhone(String value) {
  final trimmed = value.trim();
  if (!RegExp(r'^\+?[0-9][0-9 ()-]{5,}[0-9]$').hasMatch(trimmed)) return false;
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length >= 7 && digits.length <= 15;
}

bool _looksLikeUri(String value, Uri? uri) {
  final scheme = uri?.scheme.trim().toLowerCase() ?? '';
  return scheme.isNotEmpty && !{'mailto', 'tel', 'smsto', 'upi'}.contains(scheme);
}

Map<String, String> _parseWifi(String input) {
  final result = <String, String>{};
  final body = input.substring(input.indexOf(':') + 1);
  final pattern = RegExp(r'(S|P|T|H):((?:\\.|[^;])*)');
  for (final match in pattern.allMatches(body)) {
    final key = match.group(1)!;
    result[key] = match.group(2)!
        .replaceAll(r'\;', ';')
        .replaceAll(r'\:', ':')
        .replaceAll(r'\,', ',');
  }
  return result;
}

String? _vCardField(String input, String key) {
  final pattern = RegExp('^$key(?:;[^:]+)?:(.*)\$', caseSensitive: false, multiLine: true);
  return pattern.firstMatch(input)?.group(1)?.trim();
}
