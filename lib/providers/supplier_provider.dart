import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/supplier_model.dart';
import '../services/supplier_repository.dart';

class SupplierProvider extends ChangeNotifier {
  SupplierProvider({SupplierRepository? repository}) : _repository = repository ?? SupplierRepository() {
    _listen();
  }

  final SupplierRepository _repository;
  final _uuid = const Uuid();

  StreamSubscription<List<SupplierModel>>? _sub;
  List<SupplierModel> _suppliers = [];
  String _query = '';

  List<SupplierModel> get suppliers {
    if (_query.isEmpty) return _suppliers;
    final q = _query.toLowerCase();
    return _suppliers.where((s) => s.name.toLowerCase().contains(q) || s.phone.toLowerCase().contains(q) || s.email.toLowerCase().contains(q)).toList();
  }

  void _listen() {
    _sub = _repository.watchSuppliers().listen((list) {
      _suppliers = list;
      notifyListeners();
    });
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> saveSupplier({SupplierModel? existing, required String name, required String email, required String phone, String? companyName, String? address, String? paymentTerms}) async {
    final now = DateTime.now();
    if (existing == null) {
      final id = _uuid.v4();
      final supplier = SupplierModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        companyName: companyName,
        address: address,
        paymentTerms: paymentTerms,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.addSupplier(supplier);
    } else {
      final updated = existing.copyWith(
        name: name,
        email: email,
        phone: phone,
        companyName: companyName,
        address: address,
        paymentTerms: paymentTerms,
        updatedAt: now,
      );
      await _repository.updateSupplier(updated);
    }
  }

  Future<void> deleteSupplier(String id) async {
    await _repository.deleteSupplier(id);
  }

  Future<List<Map<String, dynamic>>> fetchSupplierTransactions(String supplierId) async {
    return _repository.getSupplierTransactions(supplierId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
