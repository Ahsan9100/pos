import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/product_repository.dart';
import '../services/sale_repository.dart';

class BillingProvider extends ChangeNotifier {
  BillingProvider({
    ProductRepository? productRepository,
    SaleRepository? saleRepository,
  })  : _productRepository = productRepository ?? ProductRepository(),
        _saleRepository = saleRepository ?? SaleRepository() {
    _listen();
  }

  final ProductRepository _productRepository;
  final SaleRepository _saleRepository;

  StreamSubscription<List<ProductModel>>? _productSub;
  List<ProductModel> _allProducts = [];
  List<CartItemModel> _cart = [];

  String _searchQuery = '';
  double _discountPercent = 0;
  double _taxPercent = 0;
  String? _selectedCustomerId;

  // Getters
  List<ProductModel> get allProducts => _allProducts;

  List<ProductModel> get searchResults {
    if (_searchQuery.isEmpty) return _allProducts;
    final q = _searchQuery.toLowerCase();
    return _allProducts.where((p) => p.name.toLowerCase().contains(q) || p.barcode.toLowerCase().contains(q)).toList();
  }

  List<CartItemModel> get cart => _cart;

  double get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  double get discountAmount => cartSubtotal * (_discountPercent / 100);

  double get taxableAmount => cartSubtotal - discountAmount;

  double get taxAmount => taxableAmount * (_taxPercent / 100);

  double get cartTotal => taxableAmount + taxAmount;

  double get discountPercent => _discountPercent;

  double get taxPercent => _taxPercent;

  String? get selectedCustomerId => _selectedCustomerId;

  void _listen() {
    _productSub = _productRepository.watchProducts().listen((products) {
      _allProducts = products;
      notifyListeners();
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void addToCart(ProductModel product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _cart[index] = _cart[index].copyWith(quantity: _cart[index].quantity + 1);
    } else {
      _cart.add(CartItemModel(product: product, quantity: 1));
    }
    clearSearch();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cart[index] = _cart[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _discountPercent = 0;
    _taxPercent = 0;
    _selectedCustomerId = null;
    notifyListeners();
  }

  void setDiscount(double percent) {
    _discountPercent = percent.clamp(0, 100);
    notifyListeners();
  }

  void setTax(double percent) {
    _taxPercent = percent.clamp(0, 100);
    notifyListeners();
  }

  void setSelectedCustomer(String? customerId) {
    _selectedCustomerId = customerId;
    notifyListeners();
  }

  Future<String> completeSale(String paymentMethod) async {
    if (_cart.isEmpty) throw Exception('Cart is empty');

    final items = _cart
        .map((item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'quantity': item.quantity,
              'unitPrice': item.product.salePrice,
              'subtotal': item.subtotal,
            })
        .toList();

    final saleId = await _saleRepository.saveSale(
      customerId: _selectedCustomerId,
      items: items,
      subtotal: cartSubtotal,
      discount: discountAmount,
      tax: taxAmount,
      total: cartTotal,
      paymentMethod: paymentMethod,
    );

    clearCart();
    return saleId;
  }

  @override
  void dispose() {
    _productSub?.cancel();
    super.dispose();
  }
}
