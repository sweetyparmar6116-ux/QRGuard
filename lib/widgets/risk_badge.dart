import 'package:flutter/material.dart';

import '../app.dart';
import '../models/analysis_result.dart';

class RiskBadge extends StatelessWidget {
	const RiskBadge({super.key, required this.riskLevel});

	final RiskLevel riskLevel;

	@override
	Widget build(BuildContext context) {
		final (label, color) = switch (riskLevel) {
			RiskLevel.low => ('Low Risk', QRGuardTheme.safe),
			RiskLevel.medium => ('Caution', QRGuardTheme.caution),
			RiskLevel.high => ('High Risk', QRGuardTheme.highRisk),
		};

		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
			decoration: BoxDecoration(
				color: color.withValues(alpha: 0.14),
				border: Border.all(color: color.withValues(alpha: 0.7)),
				borderRadius: BorderRadius.circular(QRGuardTheme.radiusSm),
			),
			child: Text(
				label,
				style: Theme.of(context).textTheme.labelLarge?.copyWith(
							color: color,
							fontWeight: FontWeight.w700,
						),
			),
		);
	}
}
