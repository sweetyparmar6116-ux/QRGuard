import 'package:flutter_test/flutter_test.dart';
import 'package:madl_project/models/analysis_result.dart';
import 'package:madl_project/services/url_analyzer.dart';

void main() {
  group('analyzeUrl', () {
    test('distinguishes HTTPS from plain HTTP', () {
      final https = analyzeUrl('https://example.com');
      final http = analyzeUrl('http://example.com');

      expect(https.riskLevel, RiskLevel.low);
      expect(https.findings.first.title, 'HTTPS connection');
      expect(https.findings.first.description, contains('does not guarantee'));
      expect(http.riskLevel, RiskLevel.medium);
      expect(http.findings.first.title, 'Unencrypted HTTP');
    });

    test('flags an IP-based host', () {
      final result = analyzeUrl('https://192.168.1.10/login');

      expect(result.findings.any((finding) => finding.title == 'IP-based host'), isTrue);
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('flags known URL shorteners', () {
      final result = analyzeUrl('https://bit.ly/abc123');

      expect(result.findings.any((finding) => finding.title == 'URL shortener'), isTrue);
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('flags suspicious account and urgency wording', () {
      final result = analyzeUrl('https://example.com/urgent-action-account-verification');

      expect(
        result.findings.any((finding) => finding.title == 'Potentially deceptive wording'),
        isTrue,
      );
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('rejects malformed, unsupported, and non-URL content', () {
      for (final input in [
        'hello world',
        'ftp://example.com',
        'https://',
        'https://example..com',
        'https://example.com:70000/path',
      ]) {
        final result = analyzeUrl(input);
        expect(result.isValidUrl, isFalse, reason: input);
        expect(result.findings.first.title, 'Not analyzed as a website');
      }
    });

    test('does not flag an ordinary HTTPS URL', () {
      final result = analyzeUrl('https://docs.example.org/guide/start');

      expect(result.isValidUrl, isTrue);
      expect(result.riskLevel, RiskLevel.low);
      expect(result.findings.where((finding) => finding.isWarning), isEmpty);
      expect(result.summary, contains('does not guarantee'));
    });

    test('flags credential-like user info as a strong deceptive pattern', () {
      final result = analyzeUrl('https://example.com@attacker.test/login');

      expect(result.riskLevel, RiskLevel.high);
      expect(
        result.findings.any((finding) => finding.title == 'Deceptive or unusual URL structure'),
        isTrue,
      );
    });

    test('flags Unicode and visually confusable hostname characters', () {
      final result = analyzeUrl('https://аpple.example/login');

      expect(result.findings.any((finding) => finding.title == 'Unicode or international hostname'), isTrue);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('flags suspicious encoded characters and delimiters', () {
      final result = analyzeUrl('https://example.com/%00/%0A/%2F%2F/login');

      expect(result.findings.any((finding) => finding.title == 'Suspicious encoded characters'), isTrue);
      expect(result.riskLevel, RiskLevel.high);
    });

    test('explains that shortener destinations are unverified', () {
      final result = analyzeUrl('https://tinyurl.com/demo');
      final finding = result.findings.firstWhere((item) => item.title == 'URL shortener');

      expect(finding.description, contains('final destination'));
      expect(finding.description, contains('cannot verify'));
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('does not classify a legitimate brand subdomain as misleading', () {
      final result = analyzeUrl('https://login.microsoft.com/account');

      expect(result.riskLevel, RiskLevel.low);
      expect(result.findings.any((finding) => finding.title == 'Deceptive or unusual URL structure'), isFalse);
    });

    test('flags unusual authority user-info and keeps malformed ports invalid', () {
      final credentialLike = analyzeUrl('https://example.com@attacker.test/login');
      final badPort = analyzeUrl('https://example.com:70000/login');

      expect(credentialLike.riskLevel, RiskLevel.high);
      expect(badPort.isValidUrl, isFalse);
    });

    test('handles edge-case Unicode text without throwing', () {
      final result = analyzeUrl('https://example.com/你好');

      expect(result.isValidUrl, isTrue);
      expect(result.findings.any((finding) => finding.title == 'Unicode or international hostname'), isTrue);
    });
  });
}