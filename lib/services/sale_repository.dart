import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/sale_model.dart';

class SaleRepository {
  SaleRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference get _sales => _firestore.collection('sales');

  Future<String> saveSale({
    String? customerId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required String paymentMethod,
  }) async {
    final id = _uuid.v4();
    final sale = SaleModel(
      id: id,
      customerId: customerId,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    await _sales.doc(id).set(sale.toMap());

    // Update product stock if needed
    for (final item in items) {
      final productId = item['productId'] as String?;
      final quantity = item['quantity'] as int? ?? 0;
      if (productId != null && quantity > 0) {
        await _firestore.collection('products').doc(productId).update({
          'stockQuantity': FieldValue.increment(-quantity),
          'updatedAt': Timestamp.now(),
        });
      }
    }

    return id;
  }

  Stream<List<SaleModel>> watchTodaysSales() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) => SaleModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<SaleModel>> watchAllSales() {
    return _sales
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) => SaleModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<List<SaleModel>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));

    final snap = await _sales
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((d) => SaleModel.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<SaleModel?> getSaleById(String saleId) async {
    try {
      final doc = await _sales.doc(saleId).get();
      if (doc.exists) {
        return SaleModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}
