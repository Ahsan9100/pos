import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import 'stock_adjustment_dialog.dart';
import 'stock_movements_history.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      title: 'Stock Management',
      roleLabel: 'Admin',
      userName: auth.user?.name ?? auth.user?.email ?? 'Admin',
      selectedItem: DashboardNavItem.inventory, // We'll add this to enum
      onLogout: () => auth.logout(),
      onSalesTap: () => Navigator.of(context).pushReplacementNamed('/billing'),
      onProductsTap: () => Navigator.of(context).pushReplacementNamed('/products'),
      onCategoriesTap: () => Navigator.of(context).pushReplacementNamed('/categories'),
      onCustomersTap: () => Navigator.of(context).pushReplacementNamed('/customers'),
      onSuppliersTap: () => Navigator.of(context).pushReplacementNamed('/suppliers'),
      onReportsTap: () => Navigator.of(context).pushReplacementNamed('/reports'),
      onExpensesTap: () => Navigator.of(context).pushReplacementNamed('/expenses'),
      onStockTap: () {},
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
                Tab(text: 'Current Stock'),
                Tab(text: 'Low Stock Alerts'),
                Tab(text: 'Movement History'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentStockList(context, false), // All products
                _buildCurrentStockList(context, true), // Low stock
                const StockMovementsHistory(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStockList(BuildContext context, bool onlyLowStock) {
    final productProvider = context.watch<ProductProvider>();
    final products = onlyLowStock ? productProvider.lowStockProducts : productProvider.products;
    final user = context.read<AuthProvider>().user;

    if (productProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(
        child: Text(
          onlyLowStock ? 'No low stock alerts.' : 'No products found.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isLowStock = product.isLowStock;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              child: Icon(
                isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                color: isLowStock ? Colors.red : Colors.green,
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Category: ${product.category}'),
                Text('Barcode: ${product.barcode}'),
                if (isLowStock)
                  Text(
                    'Low Stock Threshold: ${product.lowStockThreshold}',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'QTY: ${product.stockQuantity}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isLowStock ? Colors.red : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => StockAdjustmentDialog(
                        product: product,
                        userId: user?.uid ?? 'system',
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Adjust'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
