import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';

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
  bool _uploading = false;

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: const EdgeInsets.fromLTRB(28, 24, 20, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 8,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.initialProduct == null ? 'Create New Product' : 'Edit Product Details',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              fontSize: 22,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: isWide ? 920 : double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildFormColumn(isWide)),
                      const SizedBox(width: 28),
                      Expanded(flex: 2, child: _buildPreviewPanel()),
                    ],
                  )
                else ...[
                  _buildFormColumn(isWide),
                  const SizedBox(height: 24),
                  _buildPreviewPanel(),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      actions: [
        OutlinedButton(
          onPressed: _saving || _uploading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 24 : 16,
              vertical: isWide ? 18 : 14,
            ),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            foregroundColor: const Color(0xFF64748B),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          decoration: BoxDecoration(
            gradient: _saving || _uploading
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF2D5BFF), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            color: _saving || _uploading ? Colors.grey.shade300 : null,
            boxShadow: _saving || _uploading
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF2D5BFF).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: FilledButton(
            onPressed: _saving || _uploading
                ? null
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _saving = true);
                    Navigator.pop(context, _buildProduct());
                  },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 28 : 20,
                vertical: isWide ? 18 : 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_saving) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _saving ? 'Saving...' : 'Save Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF2D5BFF),
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFormColumn(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'General Information',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nameController,
          label: 'Product Name',
          icon: Icons.inventory_2_outlined,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Product name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _categoryController,
                  label: 'Category',
                  icon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _barcodeController,
                  label: 'Barcode',
                  icon: Icons.qr_code_2_outlined,
                ),
              ),
            ],
          )
        else ...[
          _buildTextField(
            controller: _categoryController,
            label: 'Category',
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Category is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _barcodeController,
            label: 'Barcode',
            icon: Icons.qr_code_2_outlined,
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'Pricing & Inventory',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _salePriceController,
                  label: 'Sale Price (Rs.)',
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid price';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _purchasePriceController,
                  label: 'Purchase Price (Rs.)',
                  icon: Icons.request_quote_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                      return 'Invalid price';
                    }
                    return null;
                  },
                ),
              ),
            ],
          )
        else ...[
          _buildTextField(
            controller: _salePriceController,
            label: 'Sale Price (Rs.)',
            icon: Icons.payments_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid price';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _purchasePriceController,
            label: 'Purchase Price (Rs.)',
            icon: Icons.request_quote_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                return 'Invalid price';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 16),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stockController,
                  label: 'Stock Quantity',
                  icon: Icons.inventory_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _lowStockController,
                  label: 'Low Stock Alert Threshold',
                  icon: Icons.warning_amber_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty && int.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          )
        else ...[
          _buildTextField(
            controller: _stockController,
            label: 'Stock Quantity',
            icon: Icons.inventory_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              if (int.tryParse(value) == null) {
                return 'Invalid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lowStockController,
            label: 'Low Stock Alert Threshold',
            icon: Icons.warning_amber_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty && int.tryParse(value) == null) {
                return 'Invalid number';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'Additional Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _descriptionController,
          label: 'Product Description',
          icon: Icons.notes_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Image',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload a high quality product photo to show in the point-of-sale grids.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: Stack(
                children: [
                  _imageUrl.isEmpty
                      ? Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFF8FAFC), Color(0xFFEEF2F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 56,
                                  color: const Color(0xFF2D5BFF).withOpacity(0.8),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No image selected',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF8FAFC),
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.network(
                            _imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5BFF)),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFFEF2F2),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined, size: 48, color: Color(0xFFEF4444)),
                                    SizedBox(height: 8),
                                    Text(
                                      'Error loading image',
                                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  if (_uploading)
                    Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Uploading picture...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving || _uploading
                      ? null
                      : () async {
                          setState(() => _uploading = true);
                          final imageUrl = await context
                              .read<ProductProvider>()
                              .pickAndUploadProductImage();
                          if (!mounted) return;
                          setState(() {
                            _uploading = false;
                            if (imageUrl != null) {
                              _imageUrl = imageUrl;
                            }
                          });
                        },
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: Text(_imageUrl.isEmpty ? 'Upload Image' : 'Change Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: const Color(0xFF475569),
                  ),
                ),
              ),
              if (_imageUrl.isNotEmpty) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _saving || _uploading
                      ? null
                      : () {
                          setState(() {
                            _imageUrl = '';
                          });
                        },
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Remove image',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
