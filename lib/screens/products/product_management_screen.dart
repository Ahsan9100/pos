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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context.read<ProductProvider>().deleteProduct(product.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Product deleted.' : 'Failed to delete product.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final products = provider.products;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            title: const Text('Product Management'),
            actions: [
              IconButton(
                onPressed: provider.loading ? null : () => provider.refresh(),
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.loading ? null : () => _openProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  const SizedBox(height: 20),
                  _buildToolbar(context, provider),
                  const SizedBox(height: 20),
                  if (provider.loading && products.isEmpty)
                    const LoadingView(message: 'Loading products...')
                  else if (provider.errorMessage != null && products.isEmpty)
                    ErrorView(message: provider.errorMessage!, onRetry: provider.refresh)
                  else if (products.isEmpty)
                    EmptyView(
                      title: 'No Products Yet',
                      message: 'Get started by creating your first product in the inventory. It will automatically be available in billing and reports.',
                      icon: Icons.inventory_2_outlined,
                      actionLabel: 'Add Product',
                      onActionPressed: () => _openProductDialog(),
                    )
                  else if (!Responsive.isMobile(context))
                    _buildDesktopTable(context, provider, products)
                  else
                    _buildMobileList(context, provider, products),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProductProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Products',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage stock, search by barcode, and keep inventory in sync with Firestore.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        if (MediaQuery.of(context).size.width >= 900) ...[
          _headerStat('Total Products', provider.totalProducts.toString()),
          const SizedBox(width: 12),
          _headerStat('Low Stock', provider.lowStockProducts.length.toString()),
        ],
      ],
    );
  }

  Widget _headerStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ProductProvider provider) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            controller: _searchController,
            onChanged: provider.search,
            decoration: InputDecoration(
              hintText: 'Search product name, barcode, category',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String?>(
            value: provider.selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All categories'),
              ),
              ...provider.categories.map(
                (category) => DropdownMenuItem<String?>(
                  value: category,
                  child: Text(category),
                ),
              ),
            ],
            onChanged: provider.filterByCategory,
          ),
        ),
      ],
    );
  }


  Widget _buildDesktopTable(
    BuildContext context,
    ProductProvider provider,
    List<ProductModel> products,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EBF4)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
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
                    DataCell(Text(product.category)),
                    DataCell(Text(product.barcode.isEmpty ? '-' : product.barcode)),
                    DataCell(Text('Rs. ${product.salePrice.toStringAsFixed(2)}')),
                    DataCell(Text(product.stockQuantity.toString())),
                    DataCell(_StatusChip(isLowStock: product.isLowStock)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => _openProductDialog(product: product),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _deleteProduct(product),
                            icon: const Icon(Icons.delete_outline),
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
                  border: Border.all(color: const Color(0xFFE6EBF4)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 58,
                      height: 58,
                      color: const Color(0xFFEFF4FF),
                      child: product.imageUrl.isEmpty
                          ? const Icon(Icons.inventory_2_outlined, color: Color(0xFF2D5BFF))
                          : Image.network(product.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${product.category} • ${product.barcode.isEmpty ? 'No barcode' : product.barcode}'),
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
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProductCell extends StatelessWidget {
  const _ProductCell({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            color: const Color(0xFFEFF4FF),
            child: product.imageUrl.isEmpty
                ? const Icon(Icons.inventory_2_outlined, color: Color(0xFF2D5BFF))
                : Image.network(product.imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              product.description?.isEmpty == true ? 'No description' : (product.description ?? ''),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isLowStock});

  final bool isLowStock;

  @override
  Widget build(BuildContext context) {
    final color = isLowStock ? const Color(0xFFEF4444) : const Color(0xFF16A34A);
    final background = isLowStock ? const Color(0xFFFFF1F2) : const Color(0xFFEAFBF0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isLowStock ? 'Low stock' : 'In stock',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
