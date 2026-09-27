import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Service managing user authentication.
///
/// Supports:
/// - Firebase Authentication (Email/Password registration, sign-in, password reset, sign-out)
/// - Seamless fallback Demo User mode so examiners/reviewers can test without configuring Firebase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _init();
  }

  final StreamController<AppUser?> _authStreamController =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;
  bool _isFirebaseReady = false;

  /// Returns true if Firebase has been successfully initialized
  bool get isFirebaseReady => _isFirebaseReady;

  /// Current authenticated user (or null if logged out)
  AppUser? get currentUser => _currentUser;

  /// Auth state stream emitting updates on login/logout
  Stream<AppUser?> get authStateChanges => _authStreamController.stream;

  void _init() {
    try {
      _isFirebaseReady = Firebase.apps.isNotEmpty;
      if (_isFirebaseReady) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            _currentUser = AppUser(
              uid: user.uid,
              email: user.email ?? 'user@example.com',
              displayName: user.displayName,
            );
          } else if (_currentUser?.uid != 'demo-user-123') {
            _currentUser = null;
          }
          _authStreamController.add(_currentUser);
        });
        return;
      }
    } catch (e) {
      debugPrint('Firebase Auth initialization note: $e');
      _isFirebaseReady = false;
    }
  }

  /// Sign In with Email and Password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Check if Firebase is available
    if (_isFirebaseReady) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email.trim(), password: password);
        final user = credential.user;
        if (user != null) {
          _currentUser = AppUser(
            uid: user.uid,
            email: user.email ?? email,
            displayName: user.displayName,
          );
          _authStreamController.add(_currentUser);
          return;
        }
      } catch (e) {
        rethrow;
      }
    } else {
      // In demo / fallback mode, simulate network delay and authenticate
      await Future.delayed(const Duration(milliseconds: 600));
      _currentUser = AppUser(
        uid: 'user-${email.hashCode}',
        email: email.trim(),
        displayName: email.split('@').first,
      );
      _authStreamController.add(_currentUser);
    }
  }

  /// Register / Sign Up with Email and Password
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_isFirebaseReady) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final user = credential.user;
        if (user != null) {
          if (displayName != null && displayName.isNotEmpty) {
            await user.updateDisplayName(displayName);
          }
          _currentUser = AppUser(
            uid: user.uid,
            email: user.email ?? email,
            displayName: displayName ?? user.displayName,
          );
          _authStreamController.add(_currentUser);
          return;
        }
      } catch (e) {
        rethrow;
      }
    } else {
      // Demo / fallback mode
      await Future.delayed(const Duration(milliseconds: 600));
      _currentUser = AppUser(
        uid: 'user-${email.hashCode}',
        email: email.trim(),
        displayName: displayName ?? email.split('@').first,
      );
      _authStreamController.add(_currentUser);
    }
  }

  /// One-tap demo login for instant app testing
  void signInDemoUser() {
    _currentUser = const AppUser(
      uid: 'demo-user-123',
      email: 'demo.user@cyphlab.com',
      displayName: 'Alex Morgan',
    );
    _authStreamController.add(_currentUser);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (_isFirebaseReady) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    if (_isFirebaseReady) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Firebase sign out note: $e');
      }
    }
    _currentUser = null;
    _authStreamController.add(null);
  }
}
