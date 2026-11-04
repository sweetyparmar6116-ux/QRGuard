import 'package:flutter/material.dart';

import '../app.dart';

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? QRGuardTheme.onTeal : QRGuardTheme.textPrimary;
    final background = primary ? QRGuardTheme.teal : QRGuardTheme.card;
    return Semantics(
      button: true,
      label: '$title. $description',
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(QRGuardTheme.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(QRGuardTheme.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary
                        ? QRGuardTheme.onTeal.withValues(alpha: 0.08)
                        : QRGuardTheme.tealSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primary ? QRGuardTheme.onTeal : QRGuardTheme.teal),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: foreground)),
                      const SizedBox(height: 3),
                      Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: primary ? QRGuardTheme.onTeal.withValues(alpha: 0.72) : QRGuardTheme.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: foreground.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
