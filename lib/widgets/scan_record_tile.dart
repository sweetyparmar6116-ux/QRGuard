import 'package:flutter/material.dart';

import '../app.dart';
import '../models/scan_record.dart';
import 'risk_badge.dart';

class ScanRecordTile extends StatelessWidget {
  const ScanRecordTile({
    super.key,
    required this.record,
    required this.onTap,
    this.dense = false,
  });

  final ScanRecord record;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final date = record.scannedAt.toLocal();
    final timeLabel =
        '${date.month}/${date.day}/${date.year} at ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
    return Card(
      margin: EdgeInsets.only(bottom: dense ? 8 : 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(QRGuardTheme.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(dense ? 14 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: QRGuardTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  RiskBadge(riskLevel: record.riskLevel),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 15, color: QRGuardTheme.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_contentTypeLabel(record.qrContentType)} • $timeLabel',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: QRGuardTheme.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: QRGuardTheme.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _contentTypeLabel(String? type) {
    return switch (type) {
      'url' => 'Website URL',
      'text' => 'Plain text',
      'phone' => 'Phone number',
      'email' => 'Email address',
      'sms' => 'SMS message',
      'wifi' => 'Wi-Fi network',
      'contact' => 'Contact card',
      'unsupported' => 'Unsupported content',
      _ => 'QR content',
    };
  }
}
