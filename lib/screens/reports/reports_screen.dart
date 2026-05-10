import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return DashboardScaffold(
      title: 'Reports Module',
      roleLabel: 'Admin',
      userName: auth.user?.name ?? auth.user?.email ?? 'Admin',
      selectedItem: DashboardNavItem.reports,
      onLogout: () => auth.logout(),
      onSalesTap: () => Navigator.of(context).pushReplacementNamed('/billing'),
      onProductsTap: () =>
          Navigator.of(context).pushReplacementNamed('/products'),
      onCategoriesTap: () =>
          Navigator.of(context).pushReplacementNamed('/categories'),
      onCustomersTap: () =>
          Navigator.of(context).pushReplacementNamed('/customers'),
      onSuppliersTap: () =>
          Navigator.of(context).pushReplacementNamed('/suppliers'),
      onReportsTap: () {},
      onExpensesTap: () =>
          Navigator.of(context).pushReplacementNamed('/expenses'),
      onStockTap: () => Navigator.of(context).pushReplacementNamed('/stock'),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF2D5BFF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2D5BFF),
              tabs: const [
                Tab(text: 'Daily Sales'),
                Tab(text: 'Monthly Sales'),
                Tab(text: 'Product Sales'),
                Tab(text: 'Profit Report'),
                Tab(text: 'Expense Report'),
                Tab(text: 'Low Stock'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlaceholder('Daily Sales Report (Coming Next)'),
                _buildPlaceholder('Monthly Sales Report (Coming Next)'),
                _buildPlaceholder('Product Sales Report (Coming Next)'),
                _buildPlaceholder('Profit Report (Coming Next)'),
                _buildPlaceholder('Expense Report (Coming Next)'),
                _buildPlaceholder('Low Stock Report (Coming Next)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
