import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import '../services/stock_repository.dart';

/// Provides state management for stock movements and adjustments.
/// Syncs in real time with the StockRepository allowing historical tracking of stock quantity overrides.
class StockProvider extends ChangeNotifier {
  StockProvider({StockRepository? repository})
      : _repository = repository ?? StockRepository() {
    _subscribe();
  }

  final StockRepository _repository;
  final Uuid _uuid = const Uuid();

  List<StockMovementModel> _movements = [];
  bool _loading = false;
  String? _errorMessage;

  List<StockMovementModel> get movements => _movements;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  void _subscribe() {
    _repository.watchStockMovements().listen(
      (items) {
        _movements = items;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> adjustStock({
    required ProductModel product,
    required StockMovementType type,
    required int quantity, // Positive value
    required String reason,
    required String userId,
  }) async {
    if (quantity <= 0) {
      _errorMessage = 'Quantity must be greater than zero.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      int change = (type == StockMovementType.stockOut || type == StockMovementType.sale) 
          ? -quantity 
          : quantity;

      if (type == StockMovementType.adjustment) {
        // If it's a specific adjustment, you might pass negative or positive, 
        // but let's assume 'quantity' input is the absolute change and user selects if it's adding or subtracting.
        // For simplicity let's rely on type = StockIn / StockOut for signs.
      }

      int newStock = product.stockQuantity + change;

      if (newStock < 0) {
        _errorMessage = 'Stock cannot be negative.';
        _setLoading(false);
        return false;
      }

      final movement = StockMovementModel(
        id: _uuid.v4(),
        productId: product.id,
        productName: product.name,
        type: type,
        quantity: change,
        previousStock: product.stockQuantity,
        newStock: newStock,
        reason: reason,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _repository.addStockMovement(movement);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
