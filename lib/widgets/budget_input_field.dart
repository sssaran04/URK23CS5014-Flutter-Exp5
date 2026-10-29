import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable TextFormField for rupee amounts.
/// Built-in validation: the value must be a positive number.
class BudgetInputField extends StatelessWidget {
  const BudgetInputField({
    super.key,
    required this.controller,
    this.label = 'Amount',
    this.hint = 'e.g. 2500',
    this.allowZero = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  /// Lets a value of 0 pass (used when resetting the monthly income).
  final bool allowZero;

  /// Returns an error message, or null when the amount is valid.
  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter an amount';
    final amount = double.tryParse(text);
    if (amount == null) return 'Enter a valid number';
    if (amount < 0 || (!allowZero && amount == 0)) {
      return 'Amount must be a positive number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: '₹ ',
        prefixIcon: const Icon(Icons.currency_rupee),
      ),
      validator: _validate,
    );
  }
}
