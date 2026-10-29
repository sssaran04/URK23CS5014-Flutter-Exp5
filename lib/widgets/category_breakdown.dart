import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/budget_provider.dart';

/// Expense per category, each with a LinearProgressIndicator bar
/// showing its share of the total expenses.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch: this widget rebuilds whenever the provider notifies.
    final budget = context.watch<BudgetProvider>();
    final byCategory = budget.expensesByCategory;
    final total = budget.totalExpenses;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (byCategory.isEmpty)
              const Text('No expenses yet.')
            else
              for (final entry in byCategory.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(entry.key.icon, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(entry.key.label)),
                          Text(
                            '${formatRupees(entry.value)}  '
                            '(${(entry.value / total * 100).toStringAsFixed(0)}%)',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: entry.value / total,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: colorScheme.surfaceContainerHighest,
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
