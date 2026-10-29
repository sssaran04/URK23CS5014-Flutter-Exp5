import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/budget_provider.dart';

/// Reusable list tile for one transaction.
/// Swipe left to delete; a SnackBar offers Undo.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final Transaction transaction;

  void _onDismissed(BuildContext context) {
    // context.read: we only need to call methods, not listen for changes.
    final budget = context.read<BudgetProvider>();
    final messenger = ScaffoldMessenger.of(context);

    budget.deleteTransaction(transaction.id); // updates app state
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${transaction.title}" deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => budget.addTransaction(transaction),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome ? Colors.green : Colors.red;
    final sign = transaction.isIncome ? '+' : '-';

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _onDismissed(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.shade50,
          child: Icon(transaction.category.icon, color: color.shade700),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category.label} • ${formatDate(transaction.date)}',
        ),
        trailing: Text(
          '$sign${formatRupees(transaction.amount)}',
          style: TextStyle(
            color: color.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
