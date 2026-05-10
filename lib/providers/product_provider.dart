import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import '../services/product_repository.dart';

/// Provides state management for products within the POS app.
/// Handles Firestore interactions including fetching, searching, and mutating product records.
/// Contains built in caching and category filtering optimizations.
class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository() {
    _subscribe();
  }

  final ProductRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  List<ProductModel> _products = [];
  bool _loading = false;
  String _query = '';
  String? _selectedCategory;
  String? _errorMessage;

  List<ProductModel> get products => _filteredProducts();
  bool get loading => _loading;
  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  List<String> get categories {
    final values = _products
        .map((e) => e.category.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  List<ProductModel> get lowStockProducts =>
      _products.where((product) => product.isLowStock).toList();

  int get totalProducts => _products.length;

  Future<void> refresh() async {
    _setLoading(true);
    try {
      final snapshot = await _repository.watchProducts().first;
      _products = snapshot;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _subscribe() {
    _repository.watchProducts().listen(
      (items) {
        _products = items;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void search(String value) {
    _query = value.toLowerCase().trim();
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<String?> pickAndUploadProductImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    return _repository.uploadProductImage(
      bytes: bytes,
      fileName: '${_uuid.v4()}_${file.name}',
      contentType: file.mimeType ?? 'image/jpeg',
    );
  }

  Future<bool> saveProduct({
    required ProductModel product,
    Uint8List? imageBytes,
    String? fileName,
    String? contentType,
  }) async {
    _setLoading(true);
    try {
      var finalProduct = product;

      if (imageBytes != null && fileName != null) {
        final imageUrl = await _repository.uploadProductImage(
          bytes: imageBytes,
          fileName: fileName,
          contentType: contentType ?? 'image/jpeg',
        );
        finalProduct = finalProduct.copyWith(imageUrl: imageUrl);
      }

      if (finalProduct.id.isEmpty) {
        final newProduct = finalProduct.copyWith(id: _uuid.v4());
        await _repository.addProduct(newProduct);
      } else {
        await _repository.updateProduct(
          finalProduct.copyWith(updatedAt: DateTime.now()),
        );
      }

      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);
    try {
      await _repository.deleteProduct(productId);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  ProductModel? productById(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  List<ProductModel> _filteredProducts() {
    return _products.where((product) {
      final matchesQuery = _query.isEmpty ||
          product.name.toLowerCase().contains(_query) ||
          product.barcode.toLowerCase().contains(_query) ||
          product.category.toLowerCase().contains(_query);

      final matchesCategory = _selectedCategory == null ||
          _selectedCategory!.isEmpty ||
          product.category == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
