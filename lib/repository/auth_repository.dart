import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/web.dart';
import 'package:once_upon_a_time/barrel.dart';

class AuthRepository {
  final auth.FirebaseAuth _firebaseAuth;
  final Logger _log;

  AuthRepository({auth.FirebaseAuth? firebaseAuth, Logger? log})
    : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
      _log = log ?? Logger();

  /// Get Firebase's current user.
  // Note: not used
  // auth.User? getUser() {
  //   try {
  //     final currentUser = _firebaseAuth.currentUser;
  //     // print('have user:');
  //     // print(currentUser);
  //     return currentUser;
  //   } catch (err) {
  //     // print('get user err: $err');
  //     _log.e('get user error', error: err);
  //     throw Exception(err);
  //   }
  // }

  /// A stream for Firebase's user changes.
  Stream<auth.User?> get user => _firebaseAuth.userChanges();

  /// Registers the user with Firebase (for developers only).
  Future<auth.User?> devRegisterUser() async {
    try {
      final userCredentials = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: secretUserEmail,
            password: secretUserPassword,
          );

      return userCredentials.user;
    } catch (err) {
      _log.e('register error', error: err);
      throw Exception(err);
    }
  }

  /// Authenticate with Firebase's email-password.
  Future<auth.User?> loginWithFirebase({
    required String email,
    required String password,
  }) async {
    try {
      final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      return userCredentials.user;
    } catch (err) {
      _log.e('login error', error: err);
      throw Exception(err);
    }
  }

  /// Log out
  Future<void> signOut() async {
    if (_firebaseAuth.currentUser != null) {
      try {
        await _firebaseAuth.signOut();
      } catch (err) {
        _log.e('firebase sign out error', error: err);
      }
    }
  }
}
