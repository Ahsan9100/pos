import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/expenses/monthly_report_widget.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExpenseProvider>();
      provider.loadMonthlyReport(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Monthly Expense Report',
      roleLabel: 'Admin',
      userName: 'Administrator',
      selectedItem: DashboardNavItem.reports,
      onSalesTap: () => Navigator.pushNamed(context, '/billing'),
      onProductsTap: () => Navigator.pushNamed(context, '/products'),
      onCategoriesTap: () => Navigator.pushNamed(context, '/categories'),
      onCustomersTap: () => Navigator.pushNamed(context, '/customers'),
      onSuppliersTap: () => Navigator.pushNamed(context, '/suppliers'),
      onReportsTap: () => Navigator.pushNamed(context, '/expense-report'),      onExpensesTap: () => Navigator.pushNamed(context, '/expenses'),      onLogout: () async {},
      body: const MonthlyReportWidget(),
    );
  }
}
