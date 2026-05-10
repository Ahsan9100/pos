import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user_model.dart';
import '../services/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  AppUserModel? _user;
  bool _loading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUserModel? get user => _user;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isCashier => _user?.isCashier ?? false;

  Stream<User?> authStateChanges() => _repository.authStateChanges();

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      final profile = await _repository.getCurrentUserProfile();
      _user = profile;
      _status = profile == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      _user = await _repository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _setLoading(true);
    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _repository.forgotPassword(email);
      _errorMessage = null;
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
