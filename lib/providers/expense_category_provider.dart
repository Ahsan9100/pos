import 'package:flutter/foundation.dart';
import '../models/expense_category_model.dart';
import '../services/expense_repository.dart';

class ExpenseCategoryProvider extends ChangeNotifier {
  ExpenseCategoryProvider({ExpenseRepository? repository})
      : _repository = repository ?? ExpenseRepository();

  final ExpenseRepository _repository;

  List<ExpenseCategoryModel> _categories = [];
  String _searchQuery = '';

  List<ExpenseCategoryModel> get categories => _categories;
  String get searchQuery => _searchQuery;

  List<ExpenseCategoryModel> get searchResults {
    if (_searchQuery.isEmpty) return _categories;
    final query = _searchQuery.toLowerCase();
    return _categories.where((category) => category.name.toLowerCase().contains(query)).toList();
  }

  void watchCategories() {
    _repository.watchExpenseCategories().listen((categories) {
      _categories = categories;
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

  Future<void> saveCategory({
    String? id,
    required String name,
    String? description,
  }) async {
    try {
      if (id == null) {
        await _repository.addExpenseCategory(
          name: name,
          description: description,
        );
      } else {
        final category = _categories.firstWhere((c) => c.id == id);
        final updated = category.copyWith(
          name: name,
          description: description,
        );
        await _repository.updateExpenseCategory(updated);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteExpenseCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
