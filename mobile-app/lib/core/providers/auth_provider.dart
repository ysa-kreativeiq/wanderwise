import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/preferences_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);

    try {
      // Listen to auth state changes
      FirebaseService.auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          await _loadUserData(user.uid);
        } else {
          _currentUser = null;
          notifyListeners();
        }
      });

      // Check for existing user
      final currentUser = FirebaseService.auth.currentUser;
      if (currentUser != null) {
        await _loadUserData(currentUser.uid);
      }
    } catch (e) {
      print('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final userDoc =
          await FirebaseService.firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromJson({
          'id': uid,
          ...userDoc.data()!,
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Fix Google Sign-In implementation
      _setError(
          'Google Sign-In temporarily disabled. Please use email/password.');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to sign in with Google: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential =
          await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _loadUserData(user.uid);
        await _saveUserToPreferences(user);
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        default:
          errorMessage = 'Failed to sign in: ${e.message}';
      }
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to sign in: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmailPassword(
      String email, String password, String name) async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential =
          await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);

        final userModel = UserModel(
          id: user.uid,
          email: user.email!,
          name: name,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          preferences: const UserPreferences(),
        );

        await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        _currentUser = userModel;
        await _saveUserToPreferences(user);
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = 'Failed to create account: ${e.message}';
      }
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to create account: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await FirebaseService.auth.sendPasswordResetEmail(email: email);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message}';
      }
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to send reset email: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);

      await FirebaseService.auth.signOut();
      // TODO: Fix Google Sign-In signOut
      // await GoogleSignIn().signOut();

      _currentUser = null;
      await PreferencesService.clearUserData();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> _createOrUpdateUser(User user) async {
    try {
      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          preferences: const UserPreferences(),
        );

        await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        _currentUser = userModel;
      } else {
        await _loadUserData(user.uid);
      }
    } catch (e) {
      print('Error creating/updating user: $e');
    }
  }

  Future<void> _saveUserToPreferences(User user) async {
    try {
      PreferencesService.userId = user.uid;
      PreferencesService.userEmail = user.email;
      PreferencesService.userName = user.displayName ?? 'User';
    } catch (e) {
      print('Error saving user to preferences: $e');
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    String? photoUrl,
    UserPreferences? preferences,
  }) async {
    try {
      _setLoading(true);

      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        _setError('No user logged in');
        _setLoading(false);
        return false;
      }

      final updates = <String, dynamic>{};
      if (name != null) {
        await user.updateDisplayName(name);
        updates['name'] = name;
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
        updates['photoUrl'] = photoUrl;
      }
      if (preferences != null) {
        updates['preferences'] = preferences.toJson();
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = DateTime.now().toIso8601String();

        await FirebaseService.firestore
            .collection('users')
            .doc(user.uid)
            .update(updates);

        await _loadUserData(user.uid);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
