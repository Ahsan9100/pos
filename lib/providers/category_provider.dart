import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/category_model.dart';
import '../services/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository() {
    _subscribe();
  }

  final CategoryRepository _repository;
  final Uuid _uuid = const Uuid();

  List<CategoryModel> _categories = [];
  bool _loading = false;
  String _query = '';
  String? _errorMessage;

  List<CategoryModel> get categories => _filteredCategories();
  bool get loading => _loading;
  String get query => _query;
  String? get errorMessage => _errorMessage;

  int get totalCategories => _categories.length;

  Future<void> refresh() async {
    _setLoading(true);
    try {
      final snapshot = await _repository.watchCategories().first;
      _categories = snapshot;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _subscribe() {
    _repository.watchCategories().listen(
      (items) {
        _categories = items;
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

  Future<bool> saveCategory({required CategoryModel category}) async {
    _setLoading(true);
    try {
      final categoryId = category.id.isEmpty ? _uuid.v4() : category.id;
      final saved = category.copyWith(
        id: categoryId,
        updatedAt: DateTime.now(),
      );

      if (category.id.isEmpty) {
        await _repository.addCategory(saved);
      } else {
        await _repository.updateCategory(saved);
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

  Future<bool> deleteCategory(String categoryId) async {
    _setLoading(true);
    try {
      await _repository.deleteCategory(categoryId);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  CategoryModel? categoryById(String categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  List<CategoryModel> _filteredCategories() {
    return _categories.where((category) {
      return _query.isEmpty ||
          category.name.toLowerCase().contains(_query) ||
          (category.description?.toLowerCase().contains(_query) ?? false);
    }).toList();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
