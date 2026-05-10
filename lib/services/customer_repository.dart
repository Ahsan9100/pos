import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  CustomerRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get _customers => _firestore.collection('customers');

  Stream<List<CustomerModel>> watchCustomers() {
    return _customers.orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => CustomerModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _customers.doc(customer.id).set(customer.toMap());
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _customers.doc(customer.id).update(customer.toMap());
  }

  Future<void> deleteCustomer(String id) async {
    await _customers.doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getPurchaseHistory(String customerId) async {
    final salesSnap = await _firestore
        .collection('sales')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return salesSnap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'total': data['total'] ?? 0,
        'items': data['items'] ?? [],
        'createdAt': data['createdAt'],
      };
    }).toList();
  }
}
