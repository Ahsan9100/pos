import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static String message(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'This email is already in use.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    if (error is FirebaseException) {
      return error.message ?? 'A Firebase error occurred (${error.code}).';
    }

    if (error is TimeoutException) {
      return 'The request timed out. Please check your connection.';
    }

    if (error is SocketException) {
      return 'No internet connection available.';
    }

    if (error is FormatException) {
      return 'Invalid data format.';
    }

    return error.toString();
  }
}
