import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../widgets/categories/category_form_dialog.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({CategoryModel? category}) async {
    final result = await showDialog<CategoryModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CategoryFormDialog(initialCategory: category),
    );

    if (result == null || !mounted) return;

    final success = await context.read<CategoryProvider>().saveCategory(category: result);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Category saved successfully.' : 'Failed to save category.')),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category'),
        content: Text('Delete ${category.name}? This will remove the category from Firestore.'),
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

    final success = await context.read<CategoryProvider>().deleteCategory(category.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Category deleted.' : 'Failed to delete category.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        final isWide = MediaQuery.of(context).size.width >= 900;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            title: const Text('Category Management'),
            actions: [
              IconButton(
                onPressed: provider.loading ? null : () => provider.refresh(),
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.loading ? null : () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Organize products by category with Firestore-backed management.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildToolbar(provider),
                  const SizedBox(height: 16),
                  if (provider.errorMessage != null) ...[
                    _buildErrorBanner(provider.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  if (provider.loading) const LinearProgressIndicator(minHeight: 3),
                  const SizedBox(height: 20),
                  if (isWide)
                    _buildDesktopTable(categories)
                  else
                    _buildMobileCards(categories),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(CategoryProvider provider) {
    return SizedBox(
      width: 360,
      child: TextField(
        controller: _searchController,
        onChanged: provider.search,
        decoration: InputDecoration(
          hintText: 'Search categories',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDesktopTable(List<CategoryModel> categories) {
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
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Updated')),
            DataColumn(label: Text('Actions')),
          ],
          rows: categories
              .map(
                (category) => DataRow(
                  cells: [
                    DataCell(Text(category.name)),
                    DataCell(Text(category.description?.isEmpty == true ? '-' : (category.description ?? '-'))),
                    DataCell(Text(_formatDate(category.createdAt))),
                    DataCell(Text(_formatDate(category.updatedAt))),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => _openForm(category: category),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _deleteCategory(category),
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

  Widget _buildMobileCards(List<CategoryModel> categories) {
    return Column(
      children: categories
          .map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE6EBF4)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.category_outlined, color: Color(0xFF2D5BFF)),
                  ),
                  title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(category.description?.isEmpty == true ? 'No description' : (category.description ?? '')),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openForm(category: category);
                      } else if (value == 'delete') {
                        _deleteCategory(category);
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
