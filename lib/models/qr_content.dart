enum QrContentType {
  url,
  payment,
  text,
  phone,
  email,
  sms,
  wifi,
  contact,
  unsupported,
}

class QrContent {
  const QrContent({
    required this.type,
    required this.displayLabel,
    required this.decodedContent,
    this.uri,
    this.phoneNumber,
    this.emailAddress,
    this.smsBody,
    this.ssid,
    this.password,
    this.contactName,
    this.payeeName,
    this.upiId,
    this.amount,
    this.currency,
  });

  final QrContentType type;
  final String displayLabel;
  final String decodedContent;
  final Uri? uri;
  final String? phoneNumber;
  final String? emailAddress;
  final String? smsBody;
  final String? ssid;
  final String? password;
  final String? contactName;
  final String? payeeName;
  final String? upiId;
  final String? amount;
  final String? currency;
}
