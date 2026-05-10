import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sales_history_provider.dart';
import '../../widgets/dashboard/dashboard_scaffold.dart';
import '../../widgets/sales_history/sales_history_filters.dart';
import '../../widgets/sales_history/sales_history_list.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesHistoryProvider>().watchSales();
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
      title: 'Sales History',
      roleLabel: 'Admin',
      userName: 'Administrator',
      selectedItem: DashboardNavItem.reports,
      onSalesTap: () => Navigator.pushNamed(context, '/billing'),
      onProductsTap: () => Navigator.pushNamed(context, '/products'),
      onCategoriesTap: () => Navigator.pushNamed(context, '/categories'),
      onCustomersTap: () => Navigator.pushNamed(context, '/customers'),
      onSuppliersTap: () => Navigator.pushNamed(context, '/suppliers'),
      onReportsTap: () => Navigator.pushNamed(context, '/sales-history'),
      onLogout: () async {},
      body: Column(
        children: [
          // Premium Header Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D5BFF), Color(0xFF7C8CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sales Overview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View and manage all your sales transactions',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick Stats
                    Consumer<SalesHistoryProvider>(
                      builder: (context, provider, _) {
                        final totalSales = provider.allSales.length;
                        final totalRevenue = provider.allSales.fold<double>(
                          0,
                          (sum, sale) => sum + sale.total,
                        );

                        return Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                label: 'Total Sales',
                                value: '$totalSales',
                                icon: Icons.trending_up_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                label: 'Total Revenue',
                                value: 'Rs. ${(totalRevenue).toStringAsFixed(0)}',
                                icon: Icons.payments_rounded,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search and Filter Section - Scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search & Filter',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Search by Invoice #, Sale ID, or Amount...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2D5BFF)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2D5BFF),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        context.read<SalesHistoryProvider>().clearSearch();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (query) {
                              context.read<SalesHistoryProvider>().setSearchQuery(query);
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Filters
                        const SalesHistoryFilters(),
                      ],
                    ),
                  ),

                  // Sales List
                  Consumer<SalesHistoryProvider>(
                    builder: (context, salesProvider, _) {
                      final sales = salesProvider.filteredSales;

                      if (sales.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  salesProvider.searchQuery.isNotEmpty || salesProvider.isFiltered
                                      ? 'No sales found'
                                      : 'No sales available',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  salesProvider.searchQuery.isNotEmpty || salesProvider.isFiltered
                                      ? 'Try adjusting your search or filters'
                                      : 'Your sales history will appear here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (salesProvider.searchQuery.isNotEmpty || salesProvider.isFiltered)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      salesProvider.resetFilters();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: const Text('Reset Filters'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2D5BFF),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SalesHistoryList(sales: sales);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// STAT BOX
// ════════════════════════════════════════════
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
