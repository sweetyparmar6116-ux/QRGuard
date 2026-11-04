import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../app.dart';
import '../models/analysis_result.dart';
import '../models/qr_content.dart';
import '../models/scan_record.dart';
import '../services/qr_content_parser.dart';
import '../services/history_service.dart';
import '../services/url_analyzer.dart';
import '../widgets/finding_tile.dart';
import '../widgets/risk_badge.dart';
import 'safety_simulator_screen.dart';

typedef LinkLaunchCallback = Future<bool> Function(Uri uri);

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.decodedContent,
    this.launchUrlOverride,
    this.analysisOverride,
    this.historyService,
    this.returnLabel = 'Return to scanning',
    this.allowReanalyse = false,
  });

  final String decodedContent;

  /// Optional platform-launch seam for deterministic widget tests.
  final LinkLaunchCallback? launchUrlOverride;
  final AnalysisResult? analysisOverride;
  final HistoryService? historyService;
  final String returnLabel;
  final bool allowReanalyse;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late AnalysisResult _analysis;
  late QrContent _content;

  @override
  void initState() {
    super.initState();
    _content = parseQrContent(widget.decodedContent);
    _analysis = widget.analysisOverride ?? analyzeUrl(widget.decodedContent);
    if (widget.analysisOverride == null) _saveScan();
  }

  Future<void> _saveScan() async {
    try {
      await (widget.historyService ?? HistoryService()).addRecord(
        ScanRecord.fromAnalysis(_analysis),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan completed, but history could not be saved.')),
      );
    }
  }

  void _reanalyse() {
    setState(() {
      _analysis = analyzeUrl(widget.decodedContent);
      _content = parseQrContent(widget.decodedContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysis;
    final content = _content;
    final isUrl = content.type == QrContentType.url;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 8),
                    Icon(
                      _contentIcon(content.type),
                      size: 48,
                      color: QRGuardTheme.teal,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isUrl
                          ? 'Website safety check'
                          : content.type == QrContentType.payment
                              ? 'Payment QR code'
                              : 'QR code details',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Chip(
                      label: Text(content.displayLabel),
                      side: BorderSide(color: QRGuardTheme.tealBorder),
                    ),
                    if (_contentDetails(content).isNotEmpty) ... [
                      const SizedBox(height: 12),
                      ..._contentDetails(content).map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            detail,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    if (content.type == QrContentType.payment) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFF102D4D), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2477D4))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('PAYMENT QR · CHECK DETAILS', style: TextStyle(color: Color(0xFF8CC5FF), fontWeight: FontWeight.bold, letterSpacing: .5)),
                          const SizedBox(height: 12),
                          Text('Payee: ${content.payeeName ?? 'Not provided'}', style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text('UPI ID: ${content.upiId ?? 'Not provided'}', style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text('Amount: ${content.amount == null ? 'Not specified' : '${content.currency ?? 'INR'} ${content.amount}'}', style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 10),
                          const Text('Check the name and amount in your payment app before approving. QRGuard cannot verify who receives the money.', style: TextStyle(color: Color(0xFFB9D7F2))),
                        ]),
                      ),
                    ],
                    if (isUrl) ... [
                      const SizedBox(height: 12),
                      Center(child: RiskBadge(riskLevel: analysis.riskLevel)),
                      const SizedBox(height: 12),
                      Text(
                        analysis.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: QRGuardTheme.textSecondary,
                              height: 1.45,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      isUrl ? 'Website link' : content.type == QrContentType.payment ? 'Payment information' : 'QR code information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: QRGuardTheme.card,
                        borderRadius:
                            BorderRadius.circular(QRGuardTheme.radiusMd),
                        border: Border.all(color: QRGuardTheme.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SelectableText(
                              widget.decodedContent,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy content',
                            icon: const Icon(Icons.copy_rounded),
                            onPressed: () => _copyUrl(context, widget.decodedContent),
                          ),
                        ],
                      ),
                    ),
                    if (isUrl) ... [
                      const SizedBox(height: 24),
                      Text('Findings',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ...analysis.findings
                          .map((finding) => FindingTile(finding: finding)),
                    ] else ... [
                      const SizedBox(height: 16),
                      Text(
                        'Check the information above. QRGuard will not open links or apps without your action.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: QRGuardTheme.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _primaryAction(context, content, analysis),
              if (widget.allowReanalyse && content.type == QrContentType.url) ... [
                OutlinedButton.icon(
                  onPressed: _reanalyse,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reanalyse URL'),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(widget.returnLabel),
              ),
              if (isUrl) ... [
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => SafetySimulatorScreen(analysis: analysis),
                    ),
                  ),
                  icon: const Icon(Icons.school_rounded),
                  label: const Text('View QR Safety Simulator'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyUrl(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard.')),
    );
  }

  Future<void> _openLink(
    BuildContext context,
    AnalysisResult analysis,
  ) async {
    final uri = Uri.tryParse(widget.decodedContent.trim());
    final scheme = uri?.scheme.toLowerCase();
    if (!analysis.isValidUrl ||
        uri == null ||
        (scheme != 'http' && scheme != 'https') ||
        uri.host.isEmpty) {
      _showMessage(context, 'Only valid HTTP or HTTPS URLs can be opened.');
      return;
    }

    if (analysis.riskLevel != RiskLevel.low) {
      final confirmed = await _confirmOpen(context, uri, analysis);
      if (confirmed != true || !context.mounted) return;
    }

    try {
        final opened = widget.launchUrlOverride != null
          ? await widget.launchUrlOverride!(uri)
          : await launcher.launchUrl(
              uri,
              mode: launcher.LaunchMode.externalApplication,
            );
      if (!context.mounted) return;
      if (!opened) {
        _showMessage(context, 'Could not open this website. Please try again.');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not open this website. Please try again.');
    }
  }

  Future<bool?> _confirmOpen(
    BuildContext context,
    Uri uri,
    AnalysisResult analysis,
  ) {
    final isHighRisk = analysis.riskLevel == RiskLevel.high;
    final warnings = analysis.findings.where((finding) => finding.isWarning);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          isHighRisk ? Icons.gpp_bad_rounded : Icons.warning_amber_rounded,
          color: isHighRisk ? QRGuardTheme.highRisk : QRGuardTheme.caution,
          size: 36,
        ),
        title: Text(isHighRisk ? 'High-risk link' : 'Review this link'),
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHighRisk
                  ? 'Several warning signals were found. Opening this link may expose you to risk.'
                  : 'This URL has warning signals. Review them before deciding whether to continue.',
            ),
            const SizedBox(height: 14),
            SelectableText(uri.toString()),
            if (warnings.isNotEmpty) ... [
              const SizedBox(height: 14),
              const Text(
                'Reasons for concern',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ...warnings.map(
                (finding) => Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text('\u2022 ${finding.title}: ${finding.description}'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Text('QRGuard uses rule-based indicators, not definitive detection.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: isHighRisk
                ? FilledButton.styleFrom(
                    backgroundColor: QRGuardTheme.highRisk,
                    foregroundColor: QRGuardTheme.textPrimary,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open anyway'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _contentIcon(QrContentType type) {
    return switch (type) {
      QrContentType.url => Icons.link_rounded,
      QrContentType.payment => Icons.account_balance_wallet_rounded,
      QrContentType.phone => Icons.phone_rounded,
      QrContentType.email => Icons.email_rounded,
      QrContentType.sms => Icons.sms_rounded,
      QrContentType.wifi => Icons.wifi_rounded,
      QrContentType.contact => Icons.badge_rounded,
      QrContentType.text => Icons.text_snippet_rounded,
      QrContentType.unsupported => Icons.help_outline_rounded,
    };
  }

  List<String> _contentDetails(QrContent content) {
    return switch (content.type) {
      QrContentType.phone => ['Number: ${content.phoneNumber ?? 'Unavailable'}'],
      QrContentType.email => ['Address: ${content.emailAddress ?? 'Unavailable'}'],
      QrContentType.sms => [
          'To: ${content.phoneNumber ?? 'Unavailable'}',
          if ((content.smsBody ?? '').isNotEmpty) 'Message: ${content.smsBody}',
        ],
      QrContentType.wifi => [
          'Network: ${content.ssid ?? 'Unavailable'}',
          if ((content.password ?? '').isNotEmpty) 'Password: [hidden]',
        ],
      QrContentType.contact => [
          if ((content.contactName ?? '').isNotEmpty)
            'Name: ${content.contactName}',
        ],
      _ => const [],
    };
  }

  Widget _primaryAction(
    BuildContext context,
    QrContent content,
    AnalysisResult analysis,
  ) {
    switch (content.type) {
      case QrContentType.payment:
        return FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2477D4), foregroundColor: Colors.white),
          onPressed: () => _confirmPayment(context, content),
          icon: const Icon(Icons.payment_rounded),
          label: const Text('Continue to payment app'),
        );
      case QrContentType.url:
        return FilledButton.icon(
          onPressed: () => _openLink(context, analysis),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Open website'),
        );
      case QrContentType.phone:
        return FilledButton.icon(
          onPressed: () => _launchExternal(
                context,
                Uri(scheme: 'tel', path: content.phoneNumber),
              ),
          icon: const Icon(Icons.phone_rounded),
          label: const Text('Dial number'),
        );
      case QrContentType.email:
        return FilledButton.icon(
          onPressed: () => _launchExternal(
                context,
                Uri(scheme: 'mailto', path: content.emailAddress),
              ),
          icon: const Icon(Icons.email_rounded),
          label: const Text('Compose email'),
        );
      case QrContentType.sms:
        return FilledButton.icon(
          onPressed: () => _launchExternal(
                context,
                Uri(scheme: 'sms', path: content.phoneNumber, queryParameters: {
                  if ((content.smsBody ?? '').isNotEmpty) 'body': content.smsBody,
                }),
              ),
          icon: const Icon(Icons.sms_rounded),
          label: const Text('Compose SMS'),
        );
      case QrContentType.wifi:
      case QrContentType.contact:
      case QrContentType.text:
      case QrContentType.unsupported:
        return FilledButton.icon(
          onPressed: () => _copyUrl(context, content.decodedContent),
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copy decoded content'),
        );
    }
  }

  Future<void> _confirmPayment(BuildContext context, QrContent content) async {
    final uri = content.uri;
    if (uri == null || uri.scheme.toLowerCase() != 'upi' ||
        uri.host.toLowerCase() != 'pay' || content.upiId == null) {
      _showMessage(context, 'This payment QR does not contain valid UPI details.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Review payment details'),
        content: Text(
          'You are leaving QRGuard to open your payment app.\n\n'
          'Payee: ${content.payeeName ?? 'Not provided'}\n'
          'UPI ID: ${content.upiId}\n'
          'Amount: ${content.amount ?? 'Not specified'}\n\n'
          'Verify the recipient and amount inside your payment app. Never enter your UPI PIN to receive money.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Continue')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _launchExternal(context, uri);
  }

  Future<void> _launchExternal(BuildContext context, Uri uri) async {
    try {
      final opened = await launcher.launchUrl(uri);
      if (!context.mounted) return;
      if (!opened) {
        _showMessage(context, 'Could not open the selected application.');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, 'Could not open the selected application.');
    }
  }
}