import '../models/category_model.dart';
import 'firebase_service.dart';

class CategoryRepository {
  CategoryRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  final FirebaseService _firebaseService;

  Stream<List<CategoryModel>> watchCategories() {
    return _firebaseService.collection('categories').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addCategory(CategoryModel category) {
    return _firebaseService.setDocument(
      collectionPath: 'categories',
      documentId: category.id,
      data: category.toMap(),
      merge: false,
    );
  }

  Future<void> updateCategory(CategoryModel category) {
    return _firebaseService.setDocument(
      collectionPath: 'categories',
      documentId: category.id,
      data: category.toMap(),
      merge: true,
    );
  }

  Future<void> deleteCategory(String categoryId) {
    return _firebaseService.deleteDocument(
      collectionPath: 'categories',
      documentId: categoryId,
    );
  }
}
