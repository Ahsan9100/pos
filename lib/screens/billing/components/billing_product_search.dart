import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/billing_provider.dart';

/// Beautiful product grid for billing screen.
/// Shows products as cards with image, name, price, and stock badge.
/// Accepts optional category filter from parent.
class BillingProductSearch extends StatelessWidget {
  const BillingProductSearch({super.key, this.selectedCategory});

  final String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, billing, _) {
        var results = billing.searchResults;

        // Apply category filter
        if (selectedCategory != null && selectedCategory!.isNotEmpty) {
          results = results
              .where((p) => p.category == selectedCategory)
              .toList();
        }

        // Loading state
        if (billing.allProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: const Color(0xFF2D5BFF).withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Loading products...',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_off_rounded,
                      size: 48, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try a different search term',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        // Product grid
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800
                ? 4
                : constraints.maxWidth > 500
                    ? 3
                    : 2;

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: results.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final product = results[index];
                final isOutOfStock = product.stockQuantity <= 0;
                final isLowStock = product.isLowStock;

                return _ProductCard(
                  name: product.name,
                  category: product.category,
                  price: product.salePrice,
                  stock: product.stockQuantity,
                  imageUrl: product.imageUrl,
                  isOutOfStock: isOutOfStock,
                  isLowStock: isLowStock,
                  onTap: isOutOfStock
                      ? null
                      : () {
                          billing.addToCart(product);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.add_shopping_cart,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${product.name} added to cart',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(milliseconds: 800),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        },
                );
              },
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════
// PRODUCT CARD
// ════════════════════════════════════════════
class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.isOutOfStock,
    required this.isLowStock,
    this.onTap,
  });

  final String name;
  final String category;
  final double price;
  final int stock;
  final String imageUrl;
  final bool isOutOfStock;
  final bool isLowStock;
  final VoidCallback? onTap;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Color scheme based on category
    final colorMap = {
      'Electronics': const Color(0xFF3B82F6),
      'Groceries': const Color(0xFF10B981),
      'Clothing': const Color(0xFFF59E0B),
    };
    final accentColor = colorMap[widget.category] ?? const Color(0xFF6366F1);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.onTap != null
            ? (_) => _animController.forward()
            : null,
        onTapUp: widget.onTap != null
            ? (_) {
                _animController.reverse();
                widget.onTap?.call();
              }
            : null,
        onTapCancel: () => _animController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isOutOfStock
                ? const Color(0xFFFEF2F2)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isOutOfStock
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / Icon area
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.08),
                        accentColor.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Product icon
                      Center(
                        child: widget.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                child: Image.network(
                                  widget.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.inventory_2_rounded,
                                    size: 36,
                                    color: accentColor.withOpacity(0.5),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.inventory_2_rounded,
                                size: 36,
                                color: accentColor.withOpacity(0.5),
                              ),
                      ),

                      // Stock badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isOutOfStock
                                ? const Color(0xFFEF4444)
                                : widget.isLowStock
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.isOutOfStock
                                ? 'Sold Out'
                                : '${widget.stock}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // Add button overlay
                      if (!widget.isOutOfStock)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Info section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category
                      Text(
                        widget.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Name
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Price
                      Text(
                        'Rs. ${widget.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
