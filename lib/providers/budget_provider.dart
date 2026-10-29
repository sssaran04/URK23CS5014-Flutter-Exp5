import 'package:flutter/material.dart';

import '../models/transaction.dart';

/// Financial status derived from the savings percentage.
enum FinancialStatus {
  excellent('Excellent - Great saving!', Colors.green, Icons.emoji_events),
  good('Good - On track', Colors.blue, Icons.thumb_up),
  warning('Warning - Tight budget', Colors.orange, Icons.warning_amber),
  overspending('Overspending - Over budget!', Colors.red, Icons.error),
  noIncome('Add your income to begin', Colors.grey, Icons.info_outline);

  const FinancialStatus(this.message, this.color, this.icon);

  final String message;
  final MaterialColor color;
  final IconData icon;
}

/// App-wide state (shared by every screen) held in a ChangeNotifier.
/// Every method that changes data calls notifyListeners(), so all widgets
/// listening through Consumer / context.watch / Selector rebuild automatically.
class BudgetProvider extends ChangeNotifier {
  BudgetProvider({List<Transaction>? transactions, this._monthlyIncome = 0})
    : _transactions = [...?transactions];

  /// Provider pre-filled with sample data so the app is not empty on launch.
  factory BudgetProvider.withSampleData() {
    final now = DateTime.now();
    return BudgetProvider(
      monthlyIncome: 50000,
      transactions: [
        Transaction(
          id: 's1',
          title: 'Freelance project',
          amount: 8000,
          type: TransactionType.income,
          category: BudgetCategory.other,
          date: now.subtract(const Duration(days: 5)),
        ),
        Transaction(
          id: 's2',
          title: 'House rent',
          amount: 15000,
          type: TransactionType.expense,
          category: BudgetCategory.rent,
          date: now.subtract(const Duration(days: 4)),
        ),
        Transaction(
          id: 's3',
          title: 'Groceries',
          amount: 4200,
          type: TransactionType.expense,
          category: BudgetCategory.food,
          date: now.subtract(const Duration(days: 2)),
        ),
        Transaction(
          id: 's4',
          title: 'Metro card recharge',
          amount: 1200,
          type: TransactionType.expense,
          category: BudgetCategory.transport,
          date: now.subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  final List<Transaction> _transactions;
  double _monthlyIncome;

  // ---------- Read-only state ----------

  /// Newest first; unmodifiable so widgets cannot change state directly.
  List<Transaction> get transactions {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  double get monthlyIncome => _monthlyIncome;

  /// Monthly income plus every income transaction.
  double get totalIncome =>
      _monthlyIncome +
      _transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get totalExpenses =>
      _transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpenses;

  /// Savings % = balance / total income x 100 (0 when there is no income).
  double get savingsPercent =>
      totalIncome == 0 ? 0 : balance / totalIncome * 100;

  /// Total spent per category, largest first.
  Map<BudgetCategory, double> get expensesByCategory {
    final totals = <BudgetCategory, double>{};
    for (final t in _transactions.where((t) => !t.isIncome)) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  FinancialStatus get financialStatus {
    if (totalIncome <= 0) return FinancialStatus.noIncome;
    final percent = savingsPercent;
    if (percent >= 30) return FinancialStatus.excellent;
    if (percent >= 10) return FinancialStatus.good;
    if (percent >= 0) return FinancialStatus.warning;
    return FinancialStatus.overspending;
  }

  // ---------- State updates (each one notifies listeners) ----------

  void setMonthlyIncome(double amount) {
    _monthlyIncome = amount;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void clearAll() {
    _transactions.clear();
    _monthlyIncome = 0;
    notifyListeners();
  }
}
