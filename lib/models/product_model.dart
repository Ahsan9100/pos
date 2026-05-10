import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.barcode,
    required this.salePrice,
    required this.purchasePrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String name;
  final String category;
  final String barcode;
  final double salePrice;
  final double purchasePrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stockQuantity <= lowStockThreshold;

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? barcode,
    double? salePrice,
    double? purchasePrice,
    int? stockQuantity,
    int? lowStockThreshold,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'barcode': barcode,
      'salePrice': salePrice,
      'purchasePrice': purchasePrice,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProductModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ProductModel.fromMap(doc.id, doc.data() ?? {});
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return ProductModel(
      id: id,
      name: (map['name'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      barcode: (map['barcode'] ?? '') as String,
      salePrice: (map['salePrice'] as num?)?.toDouble() ?? 0,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0,
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (map['lowStockThreshold'] as num?)?.toInt() ?? 0,
      imageUrl: (map['imageUrl'] ?? '') as String,
      description: map['description'] as String?,
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }

  static ProductModel empty() {
    final now = DateTime.now();
    return ProductModel(
      id: '',
      name: '',
      category: '',
      barcode: '',
      salePrice: 0,
      purchasePrice: 0,
      stockQuantity: 0,
      lowStockThreshold: 5,
      imageUrl: '',
      description: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}
