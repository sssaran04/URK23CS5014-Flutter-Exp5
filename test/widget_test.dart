import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_budget_calculator/main.dart';
import 'package:personal_budget_calculator/models/transaction.dart';
import 'package:personal_budget_calculator/providers/budget_provider.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, BudgetProvider budget) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: budget, child: const BudgetApp()),
    );
  }

  testWidgets('dashboard shows totals and status', (tester) async {
    await pumpApp(tester, BudgetProvider.withSampleData());

    expect(find.text('Excellent - Great saving!'), findsOneWidget);
    expect(find.text('₹37,600.00'), findsOneWidget); // balance
    expect(find.text('₹58,000.00'), findsOneWidget); // total income
  });

  testWidgets('adding an expense updates the balance', (tester) async {
    final budget = BudgetProvider(monthlyIncome: 10000);
    await pumpApp(tester, budget);
    expect(find.text('₹10,000.00'), findsNWidgets(2)); // balance + income

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Submitting the empty form shows validation errors.
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();
    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter an amount'), findsOneWidget);
    expect(find.text('Please select a category'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Rent');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      '9500',
    );
    await tester.tap(find.text('Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rent').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Transaction'));
    await tester.pumpAndSettle();

    // Back on the dashboard, rebuilt from the provider automatically.
    expect(budget.balance, 500);
    expect(find.text('₹500.00'), findsOneWidget);
    expect(find.text('Warning - Tight budget'), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Rent'), findsWidgets);
    expect(budget.transactions.single.category, BudgetCategory.rent);
  });
}
