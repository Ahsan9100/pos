import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../services/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({ExpenseRepository? repository}) : _repository = repository ?? ExpenseRepository();

  final ExpenseRepository _repository;

  List<ExpenseModel> _allExpenses = [];
  String _searchQuery = '';
  DateTime _selectedMonth = DateTime.now();
  Map<String, dynamic> _monthlyReport = {};

  List<ExpenseModel> get allExpenses => _allExpenses;
  String get searchQuery => _searchQuery;
  DateTime get selectedMonth => _selectedMonth;
  Map<String, dynamic> get monthlyReport => _monthlyReport;

  List<ExpenseModel> get searchResults {
    if (_searchQuery.isEmpty) return _allExpenses;
    final query = _searchQuery.toLowerCase();
    return _allExpenses.where((expense) {
      final description = expense.description.toLowerCase();
      final categoryName = expense.categoryName.toLowerCase();
      final amount = expense.amount.toStringAsFixed(2);
      return description.contains(query) || categoryName.contains(query) || amount.contains(query);
    }).toList();
  }

  List<ExpenseModel> get monthlyExpenses {
    if (_monthlyReport.isEmpty) return [];
    return _monthlyReport['expenses'] ?? [];
  }

  double get monthlyTotal {
    if (_monthlyReport.isEmpty) return 0;
    return _monthlyReport['grandTotal'] ?? 0;
  }

  Map<String, double> get categoryTotals {
    if (_monthlyReport.isEmpty) return {};
    return (_monthlyReport['categoryTotals'] ?? {}).cast<String, double>();
  }

  void watchExpenses() {
    _repository.watchAllExpenses().listen((expenses) {
      _allExpenses = expenses;
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

  Future<void> loadMonthlyReport(DateTime month) async {
    try {
      _selectedMonth = month;
      _monthlyReport = await _repository.getMonthlyExpenseReport(month: month);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveExpense({
    String? id,
    required String categoryId,
    required String categoryName,
    required double amount,
    required String description,
    String? notes,
  }) async {
    try {
      if (id == null) {
        await _repository.addExpense(
          categoryId: categoryId,
          categoryName: categoryName,
          amount: amount,
          description: description,
          notes: notes,
        );
      } else {
        final expense = _allExpenses.firstWhere((e) => e.id == id);
        final updated = expense.copyWith(
          categoryId: categoryId,
          categoryName: categoryName,
          amount: amount,
          description: description,
          notes: notes,
        );
        await _repository.updateExpense(updated);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      _allExpenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void selectMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
