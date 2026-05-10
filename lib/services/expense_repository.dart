import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../models/expense_category_model.dart';

class ExpenseRepository {
  ExpenseRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference get _expenses => _firestore.collection('expenses');
  CollectionReference get _expenseCategories => _firestore.collection('expense_categories');

  // ===== Expense CRUD Operations =====

  Stream<List<ExpenseModel>> watchAllExpenses() {
    return _expenses
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) => ExpenseModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addExpense({
    required String categoryId,
    required String categoryName,
    required double amount,
    required String description,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final expense = ExpenseModel(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      amount: amount,
      description: description,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _expenses.doc(id).set(expense.toMap());
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _expenses.doc(expense.id).update({
      'categoryId': expense.categoryId,
      'categoryName': expense.categoryName,
      'amount': expense.amount,
      'description': expense.description,
      'notes': expense.notes,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteExpense(String id) async {
    await _expenses.doc(id).delete();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final doc = await _expenses.doc(id).get();
      if (doc.exists) {
        return ExpenseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  // ===== Expense Category CRUD Operations =====

  Stream<List<ExpenseCategoryModel>> watchExpenseCategories() {
    return _expenseCategories
        .orderBy('name')
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) => ExpenseCategoryModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addExpenseCategory({
    required String name,
    String? description,
  }) async {
    final id = _uuid.v4();
    final category = ExpenseCategoryModel(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _expenseCategories.doc(id).set(category.toMap());
  }

  Future<void> updateExpenseCategory(ExpenseCategoryModel category) async {
    await _expenseCategories.doc(category.id).update({
      'name': category.name,
      'description': category.description,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteExpenseCategory(String id) async {
    await _expenseCategories.doc(id).delete();
  }

  // ===== Reporting =====

  Future<Map<String, dynamic>> getMonthlyExpenseReport({
    required DateTime month,
  }) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final startOfNextMonth = month.month == 12
        ? DateTime(month.year + 1, 1, 1)
        : DateTime(month.year, month.month + 1, 1);

    final snap = await _expenses
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('createdAt', isLessThan: Timestamp.fromDate(startOfNextMonth))
        .orderBy('createdAt', descending: true)
        .get();

    final expenses = snap.docs.map((d) => ExpenseModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();

    // Calculate totals by category
    final Map<String, double> categoryTotals = {};
    double grandTotal = 0;

    for (final expense in expenses) {
      categoryTotals[expense.categoryName] = (categoryTotals[expense.categoryName] ?? 0) + expense.amount;
      grandTotal += expense.amount;
    }

    return {
      'expenses': expenses,
      'categoryTotals': categoryTotals,
      'grandTotal': grandTotal,
      'expenseCount': expenses.length,
      'month': month,
    };
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    final snap = await _expenses
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThan: Timestamp.fromDate(endDate.add(const Duration(days: 1))))
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((d) => ExpenseModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<double> getTotalExpensesByCategory(String categoryId) async {
    final snap = await _expenses
        .where('categoryId', isEqualTo: categoryId)
        .get();

    double total = 0.0;
    for (var doc in snap.docs) {
      final expense = ExpenseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      total += expense.amount;
    }
    return total;
  }
}
