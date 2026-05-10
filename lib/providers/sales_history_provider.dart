import 'package:flutter/foundation.dart';
import '../models/sale_model.dart';
import '../services/sale_repository.dart';

class SalesHistoryProvider extends ChangeNotifier {
  SalesHistoryProvider({SaleRepository? repository}) : _repository = repository ?? SaleRepository();

  final SaleRepository _repository;

  List<SaleModel> _allSales = [];
  String _searchQuery = '';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isFiltered = false;

  List<SaleModel> get allSales => _allSales;
  String get searchQuery => _searchQuery;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isFiltered => _isFiltered;

  List<SaleModel> get filteredSales {
    List<SaleModel> results = _allSales;

    // Apply date range filter
    if (_isFiltered) {
      results = results.where((sale) {
        return sale.createdAt.isAfter(_startDate) && sale.createdAt.isBefore(_endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((sale) {
        final saleId = sale.id.toLowerCase();
        final saleIdShort = sale.id.substring(0, 8).toUpperCase().toLowerCase();
        final total = sale.total.toStringAsFixed(2);
        return saleId.contains(query) || saleIdShort.contains(query) || total.contains(query);
      }).toList();
    }

    return results;
  }

  // Watch all sales from Firestore
  void watchSales() {
    _repository.watchAllSales().listen((sales) {
      _allSales = sales;
      notifyListeners();
    });
  }

  // Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Set date range for filtering
  void setDateRange(DateTime startDate, DateTime endDate) {
    _startDate = startDate;
    _endDate = endDate;
    _isFiltered = true;
    notifyListeners();
  }

  // Clear date filter
  void clearDateFilter() {
    _isFiltered = false;
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
    notifyListeners();
  }

  // Reset all filters and search
  void resetFilters() {
    clearSearch();
    clearDateFilter();
  }

  // Get sale details by ID
  Future<SaleModel?> getSaleById(String saleId) {
    return _repository.getSaleById(saleId);
  }

  // Get sales by date range
  Future<List<SaleModel>> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    return _repository.getSalesByDateRange(startDate, endDate);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
