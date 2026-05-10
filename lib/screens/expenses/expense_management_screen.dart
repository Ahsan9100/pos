import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../../providers/expense_category_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/expenses/expense_list.dart';
import '../../widgets/expenses/expense_form_dialog.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({super.key});

  @override
  State<ExpenseManagementScreen> createState() => _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().watchExpenses();
      context.read<ExpenseCategoryProvider>().watchCategories();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Expense Management',
      roleLabel: 'Admin',
      userName: 'Administrator',
      selectedItem: DashboardNavItem.dashboard,
      onSalesTap: () => Navigator.pushNamed(context, '/billing'),
      onProductsTap: () => Navigator.pushNamed(context, '/products'),
      onCategoriesTap: () => Navigator.pushNamed(context, '/categories'),
      onCustomersTap: () => Navigator.pushNamed(context, '/customers'),
      onSuppliersTap: () => Navigator.pushNamed(context, '/suppliers'),
      onReportsTap: () => Navigator.pushNamed(context, '/sales-history'),
      onExpensesTap: () => Navigator.pushNamed(context, '/expenses'),
      onLogout: () async {},
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                context.read<ExpenseProvider>().clearSearch();
                              },
                            )
                          : null,
                    ),
                    onChanged: (query) {
                      context.read<ExpenseProvider>().setSearchQuery(query);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const ExpenseFormDialog(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ExpenseProvider>(
              builder: (context, provider, _) {
                final expenses = provider.searchResults;

                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          provider.searchQuery.isNotEmpty ? 'No expenses found' : 'No expenses recorded',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ExpenseList(expenses: expenses);
              },
            ),
          ),
        ],
      ),
    );
  }
}
