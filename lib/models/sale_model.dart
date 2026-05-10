import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  const SaleModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
  });

  final String id;
  final String? customerId;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String paymentMethod;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'items': items,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SaleModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return SaleModel(
      id: id,
      customerId: map['customerId'] as String?,
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      tax: (map['tax'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
}
