import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/expense_category_provider.dart';

class ExpenseFormDialog extends StatefulWidget {
  const ExpenseFormDialog({
    super.key,
    this.expense,
  });

  final ExpenseModel? expense;

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  late TextEditingController _descriptionCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;

  String? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _descriptionCtrl = TextEditingController(text: widget.expense?.description ?? '');
    _amountCtrl = TextEditingController(text: widget.expense?.amount.toStringAsFixed(2) ?? '');
    _notesCtrl = TextEditingController(text: widget.expense?.notes ?? '');
    _selectedCategoryId = widget.expense?.categoryId;
    _selectedCategoryName = widget.expense?.categoryName;
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Dropdown
            Consumer<ExpenseCategoryProvider>(
              builder: (context, categoryProvider, _) {
                final categories = categoryProvider.categories;

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: categories
                      .map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final category = categories.firstWhere((c) => c.id == value);
                      setState(() {
                        _selectedCategoryId = value;
                        _selectedCategoryName = category.name;
                      });
                    }
                  },
                  validator: (value) => value == null ? 'Please select a category' : null,
                );
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionCtrl,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Amount
            TextField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: 'Amount (Rs.)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixText: 'Rs. ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Add any additional notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validateAndSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _validateAndSave() async {
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_descriptionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    try {
      await context.read<ExpenseProvider>().saveExpense(
            id: widget.expense?.id,
            categoryId: _selectedCategoryId!,
            categoryName: _selectedCategoryName!,
            amount: amount,
            description: _descriptionCtrl.text,
            notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense == null ? 'Expense added successfully' : 'Expense updated successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
