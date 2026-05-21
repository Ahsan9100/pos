import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/empty_view.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/loading_view.dart';
import '../../widgets/products/product_form_dialog.dart';
import '../../core/responsive.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final _searchController = TextEditingController();
  bool _isGridView = true;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openProductDialog({ProductModel? product}) async {
    final result = await showDialog<ProductModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductFormDialog(initialProduct: product),
    );

    if (result == null || !mounted) return;

    final success = await context.read<ProductProvider>().saveProduct(product: result);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Product saved successfully.' : 'Failed to save product.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Delete ${product.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context.read<ProductProvider>().deleteProduct(product.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Product deleted.' : 'Failed to delete product.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<ProductModel> _getSortedProducts(List<ProductModel> products) {
    final list = List<ProductModel>.from(products);
    switch (_sortBy) {
      case 'name':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'price_asc':
        list.sort((a, b) => a.salePrice.compareTo(b.salePrice));
        break;
      case 'price_desc':
        list.sort((a, b) => b.salePrice.compareTo(a.salePrice));
        break;
      case 'stock_asc':
        list.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case 'stock_desc':
        list.sort((a, b) => b.stockQuantity.compareTo(a.stockQuantity));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final products = provider.products;
        final sortedProducts = _getSortedProducts(products);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              'Product Management',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: provider.loading ? null : () => provider.refresh(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh list',
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D5BFF), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D5BFF).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: provider.loading ? null : () => _openProductDialog(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Product',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              hoverElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
            ),
          ),
          body: SafeArea(
            child: provider.loading && products.isEmpty
                ? const LoadingView(message: 'Loading products...')
                : provider.errorMessage != null && products.isEmpty
                    ? ErrorView(message: provider.errorMessage!, onRetry: provider.refresh)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, provider),
                            const SizedBox(height: 20),
                            _buildStatsGrid(context, provider),
                            const SizedBox(height: 24),
                            _buildToolbar(context, provider),
                            const SizedBox(height: 20),
                            if (products.isEmpty)
                              EmptyView(
                                title: 'No Products Found',
                                message: _searchController.text.isNotEmpty || provider.selectedCategory != null
                                    ? 'No products match your current filters. Try resetting search or category selections.'
                                    : 'Get started by creating your first product in the inventory.',
                                icon: Icons.inventory_2_outlined,
                                actionLabel: 'Add Product',
                                onActionPressed: () => _openProductDialog(),
                              )
                            else if (_isGridView)
                              _buildGrid(context, provider, sortedProducts)
                            else if (!Responsive.isMobile(context))
                              _buildDesktopTable(context, sortedProducts)
                            else
                              _buildMobileList(context, provider, sortedProducts),
                          ],
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProductProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products Portal',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage stock levels, categories, pricing, and barcodes seamlessly with automatic Firestore syncing.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProductProvider provider) {
    final products = provider.products;
    final total = provider.totalProducts;
    final lowStock = provider.lowStockProducts.length;
    final outOfStock = products.where((p) => p.stockQuantity == 0).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = constraints.maxWidth < 600 
            ? 1 
            : (constraints.maxWidth < 950 ? 2 : 3);
        final double cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        final double childAspectRatio = cardWidth / 115;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              title: 'Total Products',
              value: total.toString(),
              icon: Icons.inventory_2_outlined,
              gradient: const LinearGradient(
                colors: [Color(0xFF2D5BFF), Color(0xFF6E8EFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: const Color(0xFF2D5BFF).withOpacity(0.3),
            ),
            _buildStatCard(
              title: 'Low Stock Items',
              value: lowStock.toString(),
              icon: Icons.warning_amber_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: const Color(0xFFF59E0B).withOpacity(0.3),
            ),
            _buildStatCard(
              title: 'Out of Stock',
              value: outOfStock.toString(),
              icon: Icons.error_outline_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shadowColor: const Color(0xFFEF4444).withOpacity(0.3),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              icon,
              size: 80,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ProductProvider provider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Search box
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final double width = (screenWidth - 80).clamp(0.0, 320.0);
                return SizedBox(
                  width: width,
                  child: TextField(
                    controller: _searchController,
                    onChanged: provider.search,
                    decoration: InputDecoration(
                      hintText: 'Search by name, barcode, category...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2D5BFF)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF2D5BFF), width: 1.5),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Filter dropdowns & View Toggles
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Category Filter
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final double width = (screenWidth - 80).clamp(0.0, 180.0);
                    return SizedBox(
                      width: width,
                      child: DropdownButtonFormField<String?>(
                        isExpanded: true,
                        value: provider.selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'All categories',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          ...provider.categories.map(
                            (category) => DropdownMenuItem<String?>(
                              value: category,
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                        onChanged: provider.filterByCategory,
                      ),
                    );
                  },
                ),
                // Sorting Filter
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final double width = (screenWidth - 80).clamp(0.0, 180.0);
                    return SizedBox(
                      width: width,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sort By',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'name',
                            child: Text(
                              'Name (A-Z)',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'price_asc',
                            child: Text(
                              'Price: Low to High',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'price_desc',
                            child: Text(
                              'Price: High to Low',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'stock_asc',
                            child: Text(
                              'Stock: Low to High',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'stock_desc',
                            child: Text(
                              'Stock: High to Low',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _sortBy = val;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
                // Grid / List Toggles
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                         onTap: () => setState(() => _isGridView = true),
                         child: AnimatedContainer(
                           duration: const Duration(milliseconds: 200),
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           decoration: BoxDecoration(
                             color: _isGridView ? Colors.white : Colors.transparent,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: _isGridView
                                 ? [
                                     BoxShadow(
                                       color: Colors.black.withOpacity(0.05),
                                       blurRadius: 4,
                                       offset: const Offset(0, 2),
                                     )
                                   ]
                                 : null,
                           ),
                           child: Icon(
                             Icons.grid_view_rounded,
                             color: _isGridView ? const Color(0xFF2D5BFF) : Colors.grey.shade600,
                             size: 20,
                           ),
                         ),
                       ),
                       const SizedBox(width: 4),
                       GestureDetector(
                         onTap: () => setState(() => _isGridView = false),
                         child: AnimatedContainer(
                           duration: const Duration(milliseconds: 200),
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           decoration: BoxDecoration(
                             color: !_isGridView ? Colors.white : Colors.transparent,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: !_isGridView
                                 ? [
                                     BoxShadow(
                                       color: Colors.black.withOpacity(0.05),
                                       blurRadius: 4,
                                       offset: const Offset(0, 2),
                                     )
                                   ]
                                 : null,
                           ),
                           child: Icon(
                             Icons.list_alt_rounded,
                             color: !_isGridView ? const Color(0xFF2D5BFF) : Colors.grey.shade600,
                             size: 20,
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    ProductProvider provider,
    List<ProductModel> products,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 1300) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductGridCard(
              product: product,
              onEdit: () => _openProductDialog(product: product),
              onDelete: () => _deleteProduct(product),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<ProductModel> products,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.grey.shade100,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontSize: 14,
            ),
            dataRowMaxHeight: 68,
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Barcode')),
              DataColumn(label: Text('Sale Price')),
              DataColumn(label: Text('Stock')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: products
                .map(
                  (product) => DataRow(
                    cells: [
                      DataCell(_ProductCell(product: product)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataCell(Text(product.barcode.isEmpty ? '-' : product.barcode)),
                      DataCell(
                        Text(
                          'Rs. ${product.salePrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D5BFF)),
                        ),
                      ),
                      DataCell(
                        Text(
                          product.stockQuantity.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(_StatusChip(
                        isLowStock: product.isLowStock,
                        isOutOfStock: product.stockQuantity == 0,
                      )),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _openProductDialog(product: product),
                              icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _deleteProduct(product),
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    ProductProvider provider,
    List<ProductModel> products,
  ) {
    return Column(
      children: products
          .map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 58,
                          height: 58,
                          color: const Color(0xFFEFF4FF),
                          child: product.imageUrl.isEmpty
                              ? const Icon(Icons.inventory_2_outlined, color: Color(0xFF2D5BFF))
                              : Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                        ),
                      ),
                      title: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${product.category} • ${product.barcode.isEmpty ? 'No barcode' : product.barcode}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rs. ${product.salePrice.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF2D5BFF),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openProductDialog(product: product);
                          } else if (value == 'delete') {
                            _deleteProduct(product);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.stockQuantity == 0
                                    ? 'Out of Stock'
                                    : product.isLowStock
                                        ? 'Low stock (${product.stockQuantity} left)'
                                        : '${product.stockQuantity} in stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: product.stockQuantity == 0
                                      ? const Color(0xFFEF4444)
                                      : product.isLowStock
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFF16A34A),
                                ),
                              ),
                              Text(
                                'Min Threshold: ${product.lowStockThreshold}',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (product.lowStockThreshold * 3) > 0
                                  ? (product.stockQuantity / (product.lowStockThreshold * 3)).clamp(0.0, 1.0)
                                  : 1.0,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                product.stockQuantity == 0
                                    ? const Color(0xFFEF4444)
                                    : product.isLowStock
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF16A34A),
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProductGridCard extends StatefulWidget {
  const _ProductGridCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<_ProductGridCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.stockQuantity == 0;
    final isLowStock = product.isLowStock;

    Color stockColor;
    String stockText;
    if (isOutOfStock) {
      stockColor = const Color(0xFFEF4444);
      stockText = 'Out of Stock';
    } else if (isLowStock) {
      stockColor = const Color(0xFFF59E0B);
      stockText = 'Low Stock (${product.stockQuantity} left)';
    } else {
      stockColor = const Color(0xFF10B981);
      stockText = '${product.stockQuantity} in Stock';
    }

    final maxStockForProgress = (product.lowStockThreshold * 3).toDouble();
    final stockProgress = maxStockForProgress > 0 
        ? (product.stockQuantity / maxStockForProgress).clamp(0.0, 1.0) 
        : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered 
            ? (Matrix4.identity()..translate(0, -6, 0)) 
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? const Color(0xFF2D5BFF).withOpacity(0.5) : Colors.grey.shade200,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? const Color(0xFF2D5BFF).withOpacity(0.1) 
                  : Colors.black.withOpacity(0.02),
              blurRadius: _isHovered ? 16 : 10,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.6,
                  child: Container(
                    color: const Color(0xFFF1F5F9),
                    width: double.infinity,
                    child: product.imageUrl.isEmpty
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFEEF2F6), Color(0xFFE0E7FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 40,
                                color: Color(0xFF2D5BFF),
                              ),
                            ),
                          )
                        : Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined, size: 36, color: Colors.grey),
                              ),
                            ),
                          ),
                  ),
                ),
                // Category Tag
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Warning Tags
                if (isOutOfStock || isLowStock)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isOutOfStock ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOutOfStock ? 'OUT OF STOCK' : 'LOW STOCK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.description?.isEmpty == true ? 'No description' : (product.description ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    // Stock progress indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                stockText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: stockColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                product.barcode.isEmpty ? 'N/A' : product.barcode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: stockProgress,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                    // Footer details (Price & Actions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Rs. ${product.salePrice.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Color(0xFF2D5BFF),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              onPressed: widget.onEdit,
                              tooltip: 'Edit',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF8FAFC),
                                foregroundColor: const Color(0xFF475569),
                                padding: const EdgeInsets.all(6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16),
                              onPressed: widget.onDelete,
                              tooltip: 'Delete',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFFEF2F2),
                                foregroundColor: const Color(0xFFEF4444),
                                padding: const EdgeInsets.all(6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCell extends StatelessWidget {
  const _ProductCell({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            color: const Color(0xFFEFF4FF),
            child: product.imageUrl.isEmpty
                ? const Icon(Icons.inventory_2_outlined, color: Color(0xFF2D5BFF), size: 20)
                : Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.grey, size: 18),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (product.description != null && product.description!.isNotEmpty)
              Text(
                product.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isLowStock, required this.isOutOfStock});

  final bool isLowStock;
  final bool isOutOfStock;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color background;
    String label;

    if (isOutOfStock) {
      color = const Color(0xFFEF4444);
      background = const Color(0xFFFFF1F2);
      label = 'Out of Stock';
    } else if (isLowStock) {
      color = const Color(0xFFD97706);
      background = const Color(0xFFFEF3C7);
      label = 'Low Stock';
    } else {
      color = const Color(0xFF16A34A);
      background = const Color(0xFFDCFCE7);
      label = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
