import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/billing_provider.dart';
import '../../providers/category_provider.dart';
import 'components/billing_cart_panel.dart';
import 'components/billing_product_search.dart';
import 'components/billing_summary.dart';

/// Premium POS Billing Screen with modern glassmorphism design.
/// Desktop: 3-panel layout (products | cart | summary)
/// Mobile: Tab-based navigation between products and cart
class PosBillingScreen extends StatefulWidget {
  const PosBillingScreen({super.key});

  @override
  State<PosBillingScreen> createState() => _PosBillingScreenState();
}

class _PosBillingScreenState extends State<PosBillingScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchCtrl;
  late TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleBarcodeScan(String barcode) {
    final billing = context.read<BillingProvider>();
    try {
      final product = billing.allProducts.firstWhere(
        (p) => p.barcode.toLowerCase() == barcode.toLowerCase(),
        orElse: () => throw Exception('Not found'),
      );
      billing.addToCart(product);
      _searchCtrl.clear();
      billing.setSearchQuery('');
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('${product.name} added'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Product not found'),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _searchCtrl.clear();
      billing.setSearchQuery('');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final cartCount = billing.cart.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // ── Premium Header ──
          _buildHeader(context, cartCount),
          // ── Body ──
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return _buildDesktopLayout();
                }
                return _buildMobileLayout(cartCount);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, int cartCount) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Back button
              Material(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Point of Sale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Search products, scan barcodes, complete sales',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Cart badge (mobile only)
              if (MediaQuery.of(context).size.width <= 1000)
                _CartBadge(count: cartCount),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════
  // DESKTOP LAYOUT (3 panels)
  // ════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left: Products
          Expanded(
            flex: 5,
            child: _ProductPanel(
              searchCtrl: _searchCtrl,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
              onSearch: (query) {
                context.read<BillingProvider>().setSearchQuery(query);
                setState(() {});
              },
              onBarcodeScan: _handleBarcodeScan,
            ),
          ),
          const SizedBox(width: 16),
          // Right: Cart + Summary
          SizedBox(
            width: 400,
            child: Column(
              children: [
                // Cart
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _cartHeader(),
                        const Expanded(child: BillingCartPanel()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Summary
                const BillingSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  // MOBILE LAYOUT (Tabs)
  // ════════════════════════════════════════════
  Widget _buildMobileLayout(int cartCount) {
    return Column(
      children: [
        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2D5BFF),
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: const Color(0xFF2D5BFF),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: [
              const Tab(
                icon: Icon(Icons.grid_view_rounded, size: 20),
                text: 'Products',
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount', style: const TextStyle(fontSize: 10)),
                  child: const Icon(Icons.shopping_cart_rounded, size: 20),
                ),
                text: 'Cart',
              ),
            ],
          ),
        ),
        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Products tab
              _ProductPanel(
                searchCtrl: _searchCtrl,
                selectedCategory: _selectedCategory,
                onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
                onSearch: (query) {
                  context.read<BillingProvider>().setSearchQuery(query);
                  setState(() {});
                },
                onBarcodeScan: _handleBarcodeScan,
              ),
              // Cart tab
              Column(
                children: [
                  _cartHeader(),
                  const Expanded(child: BillingCartPanel()),
                  const BillingSummary(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cartHeader() {
    return Consumer<BillingProvider>(
      builder: (context, billing, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shopping_cart_rounded,
                    color: Color(0xFF2D5BFF), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Cart',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5BFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${billing.cart.length} items',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (billing.cart.isNotEmpty)
                TextButton.icon(
                  onPressed: () => billing.clearCart(),
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════
// PRODUCT PANEL (Search + Category Chips + Grid)
// ════════════════════════════════════════════

class _ProductPanel extends StatelessWidget {
  const _ProductPanel({
    required this.searchCtrl,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearch,
    required this.onBarcodeScan,
  });

  final TextEditingController searchCtrl;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onBarcodeScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF94A3B8)),
                  suffixIcon: searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF94A3B8), size: 20),
                          onPressed: () {
                            searchCtrl.clear();
                            onSearch('');
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_2, size: 16,
                                  color: Color(0xFF2D5BFF)),
                              SizedBox(width: 4),
                              Text('Scan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2D5BFF),
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                        ),
                  hintText: 'Search products or scan barcode...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: onSearch,
                onSubmitted: onBarcodeScan,
              ),
            ),
          ),

          // Category chips
          Consumer<BillingProvider>(
            builder: (context, billing, _) {
              final categories = billing.allProducts
                  .map((p) => p.category)
                  .where((c) => c.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

              if (categories.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      isSelected: selectedCategory == null,
                      onTap: () => onCategoryChanged(null),
                    ),
                    ...categories.map(
                      (cat) => _CategoryChip(
                        label: cat,
                        isSelected: selectedCategory == cat,
                        onTap: () => onCategoryChanged(cat),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Product grid
          Expanded(
            child: BillingProductSearch(
              selectedCategory: selectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════
// CATEGORY CHIP
// ════════════════════════════════════════════
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? const Color(0xFF2D5BFF) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// CART BADGE (Mobile)
// ════════════════════════════════════════════
class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Badge(
        isLabelVisible: count > 0,
        label: Text('$count', style: const TextStyle(fontSize: 10)),
        backgroundColor: const Color(0xFFEF4444),
        child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
