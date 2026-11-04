import 'package:flutter/material.dart';

import '../app.dart';
import '../models/analysis_result.dart';

class FindingTile extends StatelessWidget {
	const FindingTile({super.key, required this.finding});

	final Finding finding;

	@override
	Widget build(BuildContext context) {
		final color = finding.isWarning ? QRGuardTheme.caution : QRGuardTheme.safe;
		return Padding(
			padding: const EdgeInsets.only(bottom: 12),
			child: Container(
				width: double.infinity,
				padding: const EdgeInsets.all(16),
				decoration: BoxDecoration(
					color: QRGuardTheme.card,
					borderRadius: BorderRadius.circular(QRGuardTheme.radiusMd),
					border: Border.all(color: QRGuardTheme.divider),
				),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Icon(
							finding.isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline,
							color: color,
							size: 22,
						),
						const SizedBox(width: 12),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										finding.title,
										style: Theme.of(context).textTheme.titleSmall?.copyWith(
													color: QRGuardTheme.textPrimary,
													fontWeight: FontWeight.w600,
												),
									),
									const SizedBox(height: 5),
									Text(
										finding.description,
										style: Theme.of(context).textTheme.bodySmall?.copyWith(
													color: QRGuardTheme.textSecondary,
													height: 1.45,
												),
									),
								],
							),
						),
					],
				),
			),
		);
	}
}
