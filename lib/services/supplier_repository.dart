import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  SupplierRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference get _suppliers => _firestore.collection('suppliers');

  Stream<List<SupplierModel>> watchSuppliers() {
    return _suppliers.orderBy('createdAt', descending: true).snapshots().map((snap) {
      return snap.docs.map((d) => SupplierModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    await _suppliers.doc(supplier.id).set(supplier.toMap());
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await _suppliers.doc(supplier.id).update(supplier.toMap());
  }

  Future<void> deleteSupplier(String id) async {
    await _suppliers.doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getSupplierTransactions(String supplierId) async {
    final purchasesSnap = await _firestore
        .collection('purchases')
        .where('supplierId', isEqualTo: supplierId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return purchasesSnap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'total': data['total'] ?? 0,
        'items': data['items'] ?? [],
        'status': data['status'] ?? 'pending',
        'createdAt': data['createdAt'],
      };
    }).toList();
  }
}
