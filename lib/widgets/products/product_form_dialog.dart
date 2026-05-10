import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/auth_text_field.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.initialProduct});

  final ProductModel? initialProduct;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _lowStockController;
  late final TextEditingController _descriptionController;
  String _imageUrl = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.initialProduct ?? ProductModel.empty();
    _nameController = TextEditingController(text: product.name);
    _categoryController = TextEditingController(text: product.category);
    _barcodeController = TextEditingController(text: product.barcode);
    _salePriceController = TextEditingController(text: product.salePrice.toStringAsFixed(2));
    _purchasePriceController = TextEditingController(text: product.purchasePrice.toStringAsFixed(2));
    _stockController = TextEditingController(text: product.stockQuantity.toString());
    _lowStockController = TextEditingController(text: product.lowStockThreshold.toString());
    _descriptionController = TextEditingController(text: product.description ?? '');
    _imageUrl = product.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _barcodeController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  ProductModel _buildProduct() {
    final now = DateTime.now();
    return ProductModel(
      id: widget.initialProduct?.id ?? '',
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      barcode: _barcodeController.text.trim(),
      salePrice: double.tryParse(_salePriceController.text.trim()) ?? 0,
      purchasePrice: double.tryParse(_purchasePriceController.text.trim()) ?? 0,
      stockQuantity: int.tryParse(_stockController.text.trim()) ?? 0,
      lowStockThreshold: int.tryParse(_lowStockController.text.trim()) ?? 5,
      imageUrl: _imageUrl,
      description: _descriptionController.text.trim(),
      createdAt: widget.initialProduct?.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(widget.initialProduct == null ? 'Add Product' : 'Edit Product'),
      content: SizedBox(
        width: isWide ? 920 : double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildFormColumn()),
                      const SizedBox(width: 20),
                      Expanded(child: _buildPreviewPanel()),
                    ],
                  )
                else ...[
                  _buildFormColumn(),
                  const SizedBox(height: 20),
                  _buildPreviewPanel(),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _saving = true);
                  Navigator.pop(context, _buildProduct());
                },
          child: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildFormColumn() {
    return Column(
      children: [
        AuthTextField(
          controller: _nameController,
          label: 'Product name',
          icon: Icons.inventory_2_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Product name is required';
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _categoryController,
          label: 'Category',
          icon: Icons.category_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Category is required';
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _barcodeController,
          label: 'Barcode',
          icon: Icons.qr_code_2_outlined,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                controller: _salePriceController,
                label: 'Sale price',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthTextField(
                controller: _purchasePriceController,
                label: 'Purchase price',
                icon: Icons.request_quote_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                controller: _stockController,
                label: 'Stock quantity',
                icon: Icons.inventory_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthTextField(
                controller: _lowStockController,
                label: 'Low stock threshold',
                icon: Icons.warning_amber_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
            prefixIcon: const Icon(Icons.notes_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Image preview',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: _imageUrl.isEmpty
                  ? Container(
                      color: const Color(0xFFEFF4FF),
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 64, color: Color(0xFF2D5BFF)),
                      ),
                    )
                  : Image.network(_imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _saving
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Uploading image...')),
                      );
                      final imageUrl = await context
                          .read<ProductProvider>()
                          .pickAndUploadProductImage();
                      if (!mounted || imageUrl == null) return;
                      setState(() => _imageUrl = imageUrl);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Image uploaded successfully.')),
                      );
                    },
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Upload / Change image'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Selected image uploads to Firebase Storage and previews here.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
