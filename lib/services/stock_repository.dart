import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stock_movement_model.dart';

class StockRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'stock_movements';
  final String _productsCollection = 'products';

  Stream<List<StockMovementModel>> watchStockMovements({int limit = 100}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StockMovementModel.fromDoc(doc)).toList();
    });
  }

  Stream<List<StockMovementModel>> watchProductStockMovements(String productId, {int limit = 50}) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StockMovementModel.fromDoc(doc)).toList();
    });
  }

  Future<void> addStockMovement(StockMovementModel movement) async {
    final batch = _firestore.batch();

    // Add movement record
    final movementRef = _firestore.collection(_collection).doc(movement.id);
    batch.set(movementRef, movement.toMap());

    // Update product stock
    final productRef = _firestore.collection(_productsCollection).doc(movement.productId);
    batch.update(productRef, {
      'stockQuantity': movement.newStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
