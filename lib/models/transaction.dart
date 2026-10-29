import 'package:flutter/material.dart';

/// Whether a transaction adds money (income) or spends it (expense).
enum TransactionType { income, expense }

/// Categories offered in the Add Transaction dropdown.
enum BudgetCategory {
  food('Food', Icons.restaurant),
  rent('Rent', Icons.home),
  transport('Transport', Icons.directions_bus),
  shopping('Shopping', Icons.shopping_bag),
  bills('Bills', Icons.receipt_long),
  entertainment('Entertainment', Icons.movie),
  salary('Salary', Icons.work),
  other('Other', Icons.category);

  const BudgetCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// One immutable income or expense entry.
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final BudgetCategory category;
  final DateTime date;

  bool get isIncome => type == TransactionType.income;
}

/// Formats an amount in rupees with 2 decimals and Indian digit grouping,
/// e.g. 125000.5 -> "₹1,25,000.50".
String formatRupees(double amount) {
  final sign = amount < 0 ? '-' : '';
  final parts = amount.abs().toStringAsFixed(2).split('.');
  var whole = parts[0];
  if (whole.length > 3) {
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    whole = '${groups.join(',')},$last3';
  }
  return '$sign₹$whole.${parts[1]}';
}

/// Formats a date as DD-MM-YYYY.
String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.year}';
