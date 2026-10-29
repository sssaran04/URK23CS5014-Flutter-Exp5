import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';

/// Shows the financial status with a colour and an icon.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Selector: rebuilds only when the status or savings % changes,
    // not on every change to the provider.
    return Selector<BudgetProvider, (FinancialStatus, double)>(
      selector: (_, budget) => (budget.financialStatus, budget.savingsPercent),
      builder: (context, data, _) {
        final (status, percent) = data;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: status.color.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: status.color, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(status.icon, color: status.color.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.message,
                      style: TextStyle(
                        color: status.color.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (status != FinancialStatus.noIncome)
                      Text(
                        'Savings: ${percent.toStringAsFixed(1)}% of income',
                        style: TextStyle(color: status.color.shade700),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
