import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../models/product_model.dart';
import 'firebase_service.dart';

class ProductRepository {
  ProductRepository({FirebaseService? firebaseService, FirebaseStorage? storage})
      : _firebaseService = firebaseService ?? FirebaseService(),
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseService _firebaseService;
  final FirebaseStorage _storage;

  Stream<List<ProductModel>> watchProducts() {
    return _firebaseService.collection('products').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final safeName = fileName.replaceAll(' ', '_');
    final ref = _storage.ref().child('product_images/$safeName');
    final metadata = SettableMetadata(contentType: contentType);
    final uploadTask = await ref.putData(bytes, metadata);
    return uploadTask.ref.getDownloadURL();
  }

  Future<void> addProduct(ProductModel product) {
    return _firebaseService.setDocument(
      collectionPath: 'products',
      documentId: product.id,
      data: product.toMap(),
      merge: false,
    );
  }

  Future<void> updateProduct(ProductModel product) {
    return _firebaseService.setDocument(
      collectionPath: 'products',
      documentId: product.id,
      data: product.toMap(),
      merge: true,
    );
  }

  Future<void> deleteProduct(String productId) {
    return _firebaseService.deleteDocument(
      collectionPath: 'products',
      documentId: productId,
    );
  }
}
