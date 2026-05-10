import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierModel {
  const SupplierModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.companyName,
    this.address,
    this.paymentTerms,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? companyName;
  final String? address;
  final String? paymentTerms;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? paymentTerms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'address': address,
      'paymentTerms': paymentTerms,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SupplierModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return SupplierModel(
      id: id,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      companyName: map['companyName'] as String?,
      address: map['address'] as String?,
      paymentTerms: map['paymentTerms'] as String?,
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }
}
