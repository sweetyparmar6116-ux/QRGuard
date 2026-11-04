import 'analysis_result.dart';
import '../services/qr_content_parser.dart';

class ScanRecord {
  const ScanRecord({
    required this.content,
    required this.isValidUrl,
    required this.riskLevel,
    required this.scannedAt,
    required this.summary,
    required this.findings,
    this.qrContentType,
  });

  final String content;
  final bool isValidUrl;
  final RiskLevel riskLevel;
  final DateTime scannedAt;
  final String summary;
  final List<Finding> findings;
  final String? qrContentType;

  factory ScanRecord.fromAnalysis(
    AnalysisResult analysis, {
    DateTime? scannedAt,
  }) {
    return ScanRecord(
      content: analysis.input,
      isValidUrl: analysis.isValidUrl,
      riskLevel: analysis.riskLevel,
      scannedAt: scannedAt ?? DateTime.now(),
      summary: analysis.summary,
      findings: List.unmodifiable(analysis.findings),
      qrContentType: parseQrContent(analysis.input).type.name,
    );
  }

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final isValidUrl = json['isValidUrl'];
    final riskName = json['riskLevel'];
    final scannedAtValue = json['scannedAt'];
    final summary = json['summary'];
    final findingsValue = json['findings'];

    if (content is! String ||
        isValidUrl is! bool ||
        riskName is! String ||
        scannedAtValue is! String ||
        summary is! String ||
        findingsValue is! List) {
      throw const FormatException('Invalid scan record fields.');
    }

    final riskLevel = RiskLevel.values.where((value) => value.name == riskName);
    if (riskLevel.isEmpty) throw const FormatException('Unknown risk level.');

    final scannedAt = DateTime.tryParse(scannedAtValue);
    if (scannedAt == null) throw const FormatException('Invalid scan date.');

    final findings = findingsValue.map((value) {
      if (value is! Map) throw const FormatException('Invalid finding.');
      final finding = Map<String, dynamic>.from(value);
      final title = finding['title'];
      final description = finding['description'];
      final isWarning = finding['isWarning'];
      if (title is! String ||
          description is! String ||
          (isWarning != null && isWarning is! bool)) {
        throw const FormatException('Invalid finding fields.');
      }
      return Finding(
        title: title,
        description: description,
        isWarning: isWarning as bool? ?? true,
      );
    }).toList(growable: false);

    final qrContentType = json['qrContentType'] as String?;

    return ScanRecord(
      content: content,
      isValidUrl: isValidUrl,
      riskLevel: riskLevel.first,
      scannedAt: scannedAt,
      summary: summary,
      findings: List.unmodifiable(findings),
      qrContentType: qrContentType,
    );
  }

  factory ScanRecord.fromAnalysisResult(
    AnalysisResult analysis, {
    DateTime? scannedAt,
  }) =>
      ScanRecord.fromAnalysis(analysis, scannedAt: scannedAt);

  AnalysisResult toAnalysisResult() => AnalysisResult(
        input: content,
        isValidUrl: isValidUrl,
        riskLevel: riskLevel,
        summary: summary,
        findings: findings,
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'isValidUrl': isValidUrl,
        'riskLevel': riskLevel.name,
        'scannedAt': scannedAt.toIso8601String(),
        'summary': summary,
        'findings': findings
            .map((finding) => {
                  'title': finding.title,
                  'description': finding.description,
                  'isWarning': finding.isWarning,
                })
            .toList(growable: false),
        'qrContentType': qrContentType,
      };
}