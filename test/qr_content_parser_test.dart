import 'package:flutter_test/flutter_test.dart';
import 'package:qrguard/models/qr_content.dart';
import 'package:qrguard/services/qr_content_parser.dart';

void main() {
  group('parseQrContent', () {
    test('detects HTTP and HTTPS URLs', () {
      expect(parseQrContent('https://example.com').type, QrContentType.url);
      expect(parseQrContent('http://example.com').type, QrContentType.url);
    });

    test('detects plain text', () {
      expect(parseQrContent('Welcome to QRGuard').type, QrContentType.text);
    });

    test('detects tel URIs and phone numbers', () {
      expect(parseQrContent('tel:+15551234567').phoneNumber, '+15551234567');
      expect(parseQrContent('+1 555 123 4567').type, QrContentType.phone);
    });

    test('detects email addresses and mailto URIs', () {
      expect(parseQrContent('person@example.com').type, QrContentType.email);
      expect(parseQrContent('mailto:person@example.com').emailAddress, 'person@example.com');
    });

    test('detects SMS URI payloads', () {
      final content = parseQrContent('SMSTO:+15551234567:Hello QRGuard');
      expect(content.type, QrContentType.sms);
      expect(content.phoneNumber, '+15551234567');
      expect(content.smsBody, 'Hello QRGuard');
    });

    test('detects Wi-Fi payloads without exposing password in parsed display fields', () {
      final content = parseQrContent(r'WIFI:S:DemoNetwork;T:WPA;P:secret123;;');
      expect(content.type, QrContentType.wifi);
      expect(content.ssid, 'DemoNetwork');
      expect(content.password, 'secret123');
    });

    test('detects vCard payloads', () {
      final content = parseQrContent('BEGIN:VCARD\nVERSION:3.0\nFN:Jane Doe\nEND:VCARD');
      expect(content.type, QrContentType.contact);
      expect(content.contactName, 'Jane Doe');
    });

    test('handles unsupported schemes and malformed payloads safely', () {
      expect(parseQrContent('ftp://example.com').type, QrContentType.unsupported);
      expect(parseQrContent('WIFI:S;;').type, QrContentType.unsupported);
      expect(parseQrContent('').type, QrContentType.unsupported);
      expect(parseQrContent('BEGIN:VCARD\nFN:Jane Doe').type, QrContentType.unsupported);
    });
  });

    test('recognises UPI payment QR and extracts payment details', () {
      final content = parseQrContent(
        'upi://pay?pa=shop%40okaxis&pn=Corner%20Store&am=125.50&cu=INR',
      );
      expect(content.type, QrContentType.payment);
      expect(content.upiId, 'shop@okaxis');
      expect(content.payeeName, 'Corner Store');
      expect(content.amount, '125.50');
      expect(content.currency, 'INR');
    });

    test('recognises UPI payment QR without a fixed amount', () {
      final content = parseQrContent('upi://pay?pa=person%40ybl&pn=Person');
      expect(content.type, QrContentType.payment);
      expect(content.upiId, 'person@ybl');
      expect(content.amount, isNull);
    });

    test('does not classify malformed UPI payload as a payment', () {
      expect(parseQrContent('upi://pay?pn=NoAccount').type, QrContentType.unsupported);
    });
}
