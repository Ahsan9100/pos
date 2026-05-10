import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/sales_history_provider.dart';
import '../../models/app_user_model.dart';
import '../../widgets/dashboard/dashboard_models.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/dashboard/dashboard_stat_card.dart';
import '../../widgets/dashboard/recent_sales_panel.dart';
import '../../widgets/dashboard/sales_chart_card.dart';
import '../../core/responsive.dart';

/// Main dashboard screen showing real-time stats from Firestore.
class PosDashboardScreen extends StatefulWidget {
  const PosDashboardScreen({super.key, required this.role});

  final dynamic role;

  @override
  State<PosDashboardScreen> createState() => _PosDashboardScreenState();
}

class _PosDashboardScreenState extends State<PosDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Start watching sales data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesHistoryProvider>().watchSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final productProvider = context.watch<ProductProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final salesProvider = context.watch<SalesHistoryProvider>();

    // Real-time stats from providers
    final totalProducts = productProvider.totalProducts;
    final lowStockCount = productProvider.lowStockProducts.length;
    final totalCustomers = customerProvider.customers.length;
    final totalSales = salesProvider.allSales.length;
    final todayRevenue = _calculateTodayRevenue(salesProvider);

    final stats = <DashboardStatModel>[
      DashboardStatModel(
        title: 'Total Sales',
        value: '$totalSales',
        delta: '${_todaySalesCount(salesProvider)} today',
        icon: Icons.point_of_sale_rounded,
        gradient: const [Color(0xFF2D5BFF), Color(0xFF7C8CFF)],
      ),
      DashboardStatModel(
        title: "Today's Revenue",
        value: 'Rs. ${todayRevenue.toStringAsFixed(0)}',
        delta: 'Live',
        icon: Icons.payments_rounded,
        gradient: const [Color(0xFFFF8A00), Color(0xFFFFB347)],
      ),
      DashboardStatModel(
        title: 'Total Products',
        value: '$totalProducts',
        delta: '$lowStockCount low stock',
        icon: Icons.inventory_2_rounded,
        gradient: const [Color(0xFF10B981), Color(0xFF63E6BE)],
      ),
      DashboardStatModel(
        title: 'Total Customers',
        value: '$totalCustomers',
        delta: 'Registered',
        icon: Icons.groups_rounded,
        gradient: const [Color(0xFF8B5CF6), Color(0xFFC084FC)],
      ),
      if (lowStockCount > 0)
        DashboardStatModel(
          title: 'Low Stock Alert',
          value: '$lowStockCount',
          delta: 'Need attention',
          icon: Icons.warning_amber_rounded,
          gradient: const [Color(0xFFEF4444), Color(0xFFF97316)],
        ),
    ];

    final roleLabel = user?.role.label ?? 'Admin';

    return DashboardScaffold(
      title: '$roleLabel Dashboard',
      roleLabel: roleLabel,
      userName: user?.name ?? user?.email ?? roleLabel,
      selectedItem: DashboardNavItem.dashboard,
      onSalesTap: () => Navigator.of(context).pushNamed('/billing'),
      onProductsTap: () => Navigator.of(context).pushNamed('/products'),
      onCategoriesTap: () => Navigator.of(context).pushNamed('/categories'),
      onCustomersTap: () => Navigator.of(context).pushNamed('/customers'),
      onSuppliersTap: () => Navigator.of(context).pushNamed('/suppliers'),
      onReportsTap: () => Navigator.of(context).pushNamed('/reports'),
      onExpensesTap: () => Navigator.of(context).pushNamed('/expenses'),
      onStockTap: () => Navigator.of(context).pushNamed('/stock'),
      onSettingsTap: () => Navigator.of(context).pushNamed('/settings'),
      onLogout: () => context.read<AuthProvider>().logout(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Track sales, customers, stock, and performance at a glance.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                final crossAxisCount = Responsive.isDesktop(context)
                    ? 4
                    : Responsive.isTablet(context)
                        ? 2
                        : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.6,
                  ),
                  itemBuilder: (context, index) {
                    return DashboardStatCard(stat: stats[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                final isWide = Responsive.isDesktop(context);
                final chartData = _buildChartData(salesProvider);
                final chart = SalesChartCard(data: chartData);
                final recentSales = RecentSalesPanel(
                  sales: _buildRecentSales(salesProvider),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: chart),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: recentSales),
                    ],
                  );
                }

                return Column(
                  children: [chart, const SizedBox(height: 24), recentSales],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ────────── Helper Methods ──────────

  double _calculateTodayRevenue(SalesHistoryProvider provider) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return provider.allSales
        .where((s) => s.createdAt.isAfter(startOfDay))
        .fold(0.0, (sum, s) => sum + s.total);
  }

  int _todaySalesCount(SalesHistoryProvider provider) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return provider.allSales.where((s) => s.createdAt.isAfter(startOfDay)).length;
  }

  List<SalesPoint> _buildChartData(SalesHistoryProvider provider) {
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<SalesPoint> points = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final dayTotal = provider.allSales
          .where((s) => s.createdAt.isAfter(dayStart) && s.createdAt.isBefore(dayEnd))
          .fold(0.0, (sum, s) => sum + s.total);
      points.add(SalesPoint(day: dayNames[date.weekday - 1], value: dayTotal / 1000));
    }

    return points;
  }

  List<RecentSaleModel> _buildRecentSales(SalesHistoryProvider provider) {
    final recent = provider.allSales.take(5).toList();
    return recent.map((sale) {
      final timeAgo = _timeAgo(sale.createdAt);
      return RecentSaleModel(
        invoiceNo: 'INV-${sale.id.substring(0, 6).toUpperCase()}',
        customer: sale.customerId ?? 'Walk-in',
        amount: sale.total,
        timeLabel: timeAgo,
        status: 'Paid',
      );
    }).toList();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }
}
