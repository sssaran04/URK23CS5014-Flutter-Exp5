import 'package:flutter_test/flutter_test.dart';
import 'package:personal_budget_calculator/models/transaction.dart';
import 'package:personal_budget_calculator/providers/budget_provider.dart';

Transaction tx(
  String id,
  double amount,
  TransactionType type, [
  BudgetCategory category = BudgetCategory.other,
]) => Transaction(
  id: id,
  title: 'T$id',
  amount: amount,
  type: type,
  category: category,
  date: DateTime(2026, 10, 1),
);

/// Provider with 10000 income and the given expense total.
BudgetProvider withExpense(double expense) => BudgetProvider(
  transactions: [
    tx('i', 10000, TransactionType.income, BudgetCategory.salary),
    if (expense > 0) tx('e', expense, TransactionType.expense),
  ],
);

void main() {
  group('BudgetProvider totals', () {
    test('totals, balance and savings percent', () {
      final budget = BudgetProvider(
        monthlyIncome: 20000,
        transactions: [
          tx('1', 5000, TransactionType.income),
          tx('2', 7000, TransactionType.expense, BudgetCategory.rent),
          tx('3', 3000, TransactionType.expense, BudgetCategory.food),
          tx('4', 2000, TransactionType.expense, BudgetCategory.food),
        ],
      );
      expect(budget.totalIncome, 25000);
      expect(budget.totalExpenses, 12000);
      expect(budget.balance, 13000);
      expect(budget.savingsPercent, closeTo(52, 0.001));
      expect(budget.expensesByCategory, {
        BudgetCategory.rent: 7000,
        BudgetCategory.food: 5000,
      });
    });

    test('add, delete and clearAll notify listeners', () {
      final budget = BudgetProvider();
      var notified = 0;
      budget.addListener(() => notified++);

      budget.addTransaction(tx('a', 1000, TransactionType.income));
      expect(budget.balance, 1000);
      budget.addTransaction(tx('b', 400, TransactionType.expense));
      expect(budget.balance, 600);
      budget.deleteTransaction('b');
      expect(budget.balance, 1000);
      budget.clearAll();
      expect(budget.transactions, isEmpty);
      expect(notified, 4);
    });
  });

  group('BudgetProvider financial status', () {
    test('no income -> Add your income to begin', () {
      final budget = BudgetProvider(
        transactions: [tx('e', 500, TransactionType.expense)],
      );
      expect(budget.financialStatus, FinancialStatus.noIncome);
      expect(budget.financialStatus.message, 'Add your income to begin');
    });

    test('>= 30% -> Excellent', () {
      expect(withExpense(7000).financialStatus, FinancialStatus.excellent);
      expect(withExpense(0).financialStatus, FinancialStatus.excellent);
    });

    test('10-29% -> Good', () {
      expect(withExpense(7001).financialStatus, FinancialStatus.good);
      expect(withExpense(9000).financialStatus, FinancialStatus.good);
    });

    test('0-9% -> Warning', () {
      expect(withExpense(9500).financialStatus, FinancialStatus.warning);
      expect(withExpense(10000).financialStatus, FinancialStatus.warning);
    });

    test('< 0 -> Overspending', () {
      final budget = withExpense(12000);
      expect(budget.balance, -2000);
      expect(budget.financialStatus, FinancialStatus.overspending);
      expect(budget.financialStatus.message, 'Overspending - Over budget!');
    });
  });

  test('formatRupees uses 2 decimals and Indian grouping', () {
    expect(formatRupees(0), '₹0.00');
    expect(formatRupees(999.5), '₹999.50');
    expect(formatRupees(125000), '₹1,25,000.00');
    expect(formatRupees(-2000), '-₹2,000.00');
  });
}
