import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../models/stock_movement_model.dart';
import '../../providers/stock_provider.dart';

class StockAdjustmentDialog extends StatefulWidget {
  const StockAdjustmentDialog({
    super.key,
    required this.product,
    required this.userId,
  });

  final ProductModel product;
  final String userId;

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  StockMovementType _selectedType = StockMovementType.stockIn;
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() async {
    final qtyStr = _quantityController.text.trim();
    final qty = int.tryParse(qtyStr);
    
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive quantity.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await context.read<StockProvider>().adjustStock(
      product: widget.product,
      type: _selectedType,
      quantity: qty,
      reason: _reasonController.text.trim().isEmpty ? 'Manual adjustment' : _reasonController.text.trim(),
      userId: widget.userId,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated successfully.')),
      );
    } else {
      final error = context.read<StockProvider>().errorMessage ?? 'Failed to update stock.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust Stock: ${widget.product.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Stock: ${widget.product.stockQuantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButtonFormField<StockMovementType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Movement Type',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: StockMovementType.stockIn,
                  child: Text(StockMovementType.stockIn.label),
                ),
                DropdownMenuItem(
                  value: StockMovementType.stockOut,
                  child: Text(StockMovementType.stockOut.label),
                ),
                DropdownMenuItem(
                  value: StockMovementType.adjustment,
                  child: Text(StockMovementType.adjustment.label),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason / Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
        ),
      ],
    );
  }
}
