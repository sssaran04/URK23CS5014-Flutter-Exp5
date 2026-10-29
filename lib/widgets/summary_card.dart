import 'package:flutter/material.dart';

import '../models/transaction.dart';

/// Reusable card showing one total: Total Income, Total Expenses or Balance.
/// It is a plain StatelessWidget; the parent passes in the value read from
/// the provider, so this card stays independent of state management.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.large = false,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  /// The Balance card is shown larger than the other two.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: EdgeInsets.all(large ? 18 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: large ? 22 : 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    style: textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatRupees(amount),
                style:
                    (large ? textTheme.headlineMedium : textTheme.titleMedium)
                        ?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
