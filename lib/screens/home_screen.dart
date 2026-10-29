import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../widgets/budget_input_field.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/status_banner.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

/// Filter tabs for the transaction list.
enum TransactionFilter { all, income, expense }

/// Summary dashboard + transaction list.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Local (ephemeral) UI state: only this screen needs it, so setState is
  // enough. The budget data itself lives in the BudgetProvider.
  TransactionFilter _filter = TransactionFilter.all;

  Future<void> _editMonthlyIncome() async {
    final budget = context.read<BudgetProvider>();
    final controller = TextEditingController(
      text: budget.monthlyIncome.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Monthly Income'),
        content: Form(
          key: formKey,
          child: BudgetInputField(
            controller: controller,
            label: 'Monthly income',
            allowZero: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, double.parse(controller.text));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount != null) budget.setMonthlyIncome(amount); // updates app state
  }

  Future<void> _confirmClearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This removes every transaction and resets the monthly income.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) context.read<BudgetProvider>().clearAll();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch: the list below rebuilds when transactions change.
    final transactions = context.watch<BudgetProvider>().transactions;
    final visible = switch (_filter) {
      TransactionFilter.all => transactions,
      TransactionFilter.income =>
        transactions.where((t) => t.isIncome).toList(),
      TransactionFilter.expense =>
        transactions.where((t) => !t.isIncome).toList(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Calculator'),
        actions: [
          IconButton(
            tooltip: 'Set monthly income',
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: _editMonthlyIncome,
          ),
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _confirmClearAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
        children: [
          const StatusBanner(),
          const SizedBox(height: 10),
          // Consumer: only this part rebuilds with the new totals.
          Consumer<BudgetProvider>(
            builder: (context, budget, _) => Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SummaryCard(
                    title: 'Balance',
                    amount: budget.balance,
                    icon: Icons.savings,
                    color: budget.balance < 0 ? Colors.red : Colors.teal,
                    large: true,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Income',
                        amount: budget.totalIncome,
                        icon: Icons.trending_up,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Expenses',
                        amount: budget.totalExpenses,
                        icon: Icons.trending_down,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const CategoryBreakdown(),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Swipe left to delete',
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final f in TransactionFilter.values)
                ChoiceChip(
                  label: Text(switch (f) {
                    TransactionFilter.all => 'All',
                    TransactionFilter.income => 'Income',
                    TransactionFilter.expense => 'Expense',
                  }),
                  selected: _filter == f,
                  // setState: changes only this screen's local filter.
                  onSelected: (_) => setState(() => _filter = f),
                ),
            ],
          ),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No transactions to show.')),
            )
          else
            for (final t in visible) TransactionTile(transaction: t),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AddTransactionScreen.routeName),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
