import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';
import 'firebase_service.dart';

class AuthRepository {
  AuthRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  final FirebaseService _firebaseService;

  Stream<User?> authStateChanges() => _firebaseService.authStateChanges();

  Future<AppUserModel?> getCurrentUserProfile() async {
    final user = _firebaseService.currentUser;
    if (user == null) return null;

    final snapshot = await _firebaseService.getDocument(
      collectionPath: 'users',
      documentId: user.uid,
    );

    if (!snapshot.exists || snapshot.data() == null) {
      return AppUserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: UserRole.admin, // Default to admin so owner has full access
        name: user.displayName,
      );
    }

    return AppUserModel.fromMap(snapshot.data()!);
  }

  Future<AppUserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final credential = await _firebaseService.registerWithEmailPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Registration failed.');
    }

    await user.updateDisplayName(name);
    final profile = AppUserModel(
      uid: user.uid,
      email: email,
      role: role,
      name: name,
    );

    await _firebaseService.setDocument(
      collectionPath: 'users',
      documentId: user.uid,
      data: profile.toMap(),
    );

    return profile;
  }

  Future<AppUserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseService.signInWithEmailPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Login failed.');
    }

    final profile = await getCurrentUserProfile();
    if (profile == null) {
      return AppUserModel(
        uid: user.uid,
        email: user.email ?? email,
        role: UserRole.admin,
        name: user.displayName,
      );
    }

    return profile;
  }

  Future<void> forgotPassword(String email) {
    return _firebaseService.sendPasswordResetEmail(email);
  }

  Future<void> logout() => _firebaseService.signOut();
}
