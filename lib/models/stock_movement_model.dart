import 'package:cloud_firestore/cloud_firestore.dart';

enum StockMovementType {
  stockIn,
  stockOut,
  adjustment,
  sale,
  returnItem,
}

extension StockMovementTypeExtension on StockMovementType {
  String get label {
    switch (this) {
      case StockMovementType.stockIn:
        return 'Stock In';
      case StockMovementType.stockOut:
        return 'Stock Out';
      case StockMovementType.adjustment:
        return 'Adjustment';
      case StockMovementType.sale:
        return 'Sale';
      case StockMovementType.returnItem:
        return 'Return';
    }
  }

  static StockMovementType fromString(String value) {
    return StockMovementType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StockMovementType.adjustment,
    );
  }
}

class StockMovementModel {
  const StockMovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.reason,
    required this.userId,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String productName;
  final StockMovementType type;
  final int quantity; // Can be positive or negative
  final int previousStock;
  final int newStock;
  final String reason;
  final String userId;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'type': type.name,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'reason': reason,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StockMovementModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return StockMovementModel.fromMap(doc.id, doc.data() ?? {});
  }

  factory StockMovementModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return StockMovementModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      type: StockMovementTypeExtension.fromString(map['type'] ?? ''),
      quantity: (map['quantity'] ?? 0).toInt(),
      previousStock: (map['previousStock'] ?? 0).toInt(),
      newStock: (map['newStock'] ?? 0).toInt(),
      reason: map['reason'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
}
