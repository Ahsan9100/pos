import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/expenses/expense_form_dialog.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({
    super.key,
    required this.expenses,
  });

  final List<ExpenseModel> expenses;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    if (isWide) {
      return _buildDesktopList(context, dateFormat, currencyFormat);
    } else {
      return _buildMobileList(context, dateFormat, currencyFormat);
    }
  }

  Widget _buildDesktopList(BuildContext context, DateFormat dateFormat, NumberFormat currencyFormat) {
    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Actions')),
        ],
        rows: expenses.map((expense) {
          return DataRow(cells: [
            DataCell(Text(dateFormat.format(expense.createdAt))),
            DataCell(Text(expense.categoryName)),
            DataCell(Text(expense.description)),
            DataCell(Text('Rs. ${currencyFormat.format(expense.amount)}')),
            DataCell(_buildActionButtons(context, expense)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, DateFormat dateFormat, NumberFormat currencyFormat) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.categoryName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            dateFormat.format(expense.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs. ${currencyFormat.format(expense.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(expense.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Note: ${expense.notes}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
                const SizedBox(height: 12),
                _buildActionButtons(context, expense),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ExpenseModel expense) {
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit'),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ExpenseFormDialog(expense: expense),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete, size: 16),
          label: const Text('Delete'),
          onPressed: () => _showDeleteConfirm(context, expense),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirm(BuildContext context, ExpenseModel expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete this expense (Rs. ${expense.amount.toStringAsFixed(2)})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ExpenseProvider>().deleteExpense(expense.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
