import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/customer_model.dart';
import '../services/customer_repository.dart';

class CustomerProvider extends ChangeNotifier {
  CustomerProvider({CustomerRepository? repository}) : _repository = repository ?? CustomerRepository() {
    _listen();
  }

  final CustomerRepository _repository;
  final _uuid = const Uuid();

  StreamSubscription<List<CustomerModel>>? _sub;
  List<CustomerModel> _customers = [];
  String _query = '';

  List<CustomerModel> get customers {
    if (_query.isEmpty) return _customers;
    final q = _query.toLowerCase();
    return _customers.where((c) => c.name.toLowerCase().contains(q) || c.phone.toLowerCase().contains(q) || c.email.toLowerCase().contains(q)).toList();
  }

  void _listen() {
    _sub = _repository.watchCustomers().listen((list) {
      _customers = list;
      notifyListeners();
    });
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> saveCustomer({CustomerModel? existing, required String name, required String email, required String phone, String? address}) async {
    final now = DateTime.now();
    if (existing == null) {
      final id = _uuid.v4();
      final customer = CustomerModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.addCustomer(customer);
    } else {
      final updated = existing.copyWith(
        name: name,
        email: email,
        phone: phone,
        address: address,
        updatedAt: now,
      );
      await _repository.updateCustomer(updated);
    }
  }

  Future<void> deleteCustomer(String id) async {
    await _repository.deleteCustomer(id);
  }

  Future<List<Map<String, dynamic>>> fetchPurchaseHistory(String customerId) async {
    return _repository.getPurchaseHistory(customerId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
