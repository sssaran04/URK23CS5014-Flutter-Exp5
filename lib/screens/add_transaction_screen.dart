import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_input_field.dart';

/// Form to add an income or an expense.
/// The form fields are local state; the saved transaction goes to app state.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  static const routeName = '/add';

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  BudgetCategory? _category;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      type: _type,
      category: _category!,
      date: _date,
    );

    // Update app state; the home screen rebuilds on its own.
    context.read<BudgetProvider>().addTransaction(transaction);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('"${transaction.title}" added')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Electricity bill',
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a title'
                  : null,
            ),
            const SizedBox(height: 16),
            BudgetInputField(controller: _amountController),
            const SizedBox(height: 16),
            DropdownButtonFormField<BudgetCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final c in BudgetCategory.values)
                  DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(c.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(c.label),
                      ],
                    ),
                  ),
              ],
              onChanged: (c) => setState(() => _category = c),
              validator: (c) => c == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text('Date: ${formatDate(_date)}'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
