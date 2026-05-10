import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_error_handler.dart';

class FirebaseService {
  FirebaseService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<T> execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      throw Exception(FirebaseErrorHandler.message(error));
    }
  }

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) {
    return execute(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return execute(
      () => _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return execute(() => _auth.sendPasswordResetEmail(email: email));
  }

  Future<void> signOut() {
    return execute(() => _auth.signOut());
  }

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  DocumentReference<Map<String, dynamic>> document(
    String collectionPath,
    String documentId,
  ) {
    return _firestore.collection(collectionPath).doc(documentId);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return execute(
      () => _firestore.collection(collectionPath).doc(documentId).get(),
    );
  }

  Future<void> setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) {
    return execute(
      () => _firestore.collection(collectionPath).doc(documentId).set(
            data,
            SetOptions(merge: merge),
          ),
    );
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return execute(
      () => _firestore.collection(collectionPath).doc(documentId).update(data),
    );
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return execute(
      () => _firestore.collection(collectionPath).doc(documentId).delete(),
    );
  }

  Future<DocumentReference<Map<String, dynamic>>> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) {
    return execute(() => _firestore.collection(collectionPath).add(data));
  }
}
