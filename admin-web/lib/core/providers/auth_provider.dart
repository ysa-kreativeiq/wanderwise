import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
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
      SupabaseService.authStateChanges.listen((AuthState data) async {
        final user = data.session?.user;
        if (user != null) {
          await _loadUserData(user.id);
        } else {
          _currentUser = null;
          notifyListeners();
        }
      });

      // Check for existing user
      final currentUser = SupabaseService.getCurrentUser();
      if (currentUser != null) {
        _currentUser = currentUser;
        notifyListeners();
      }
    } catch (e) {
      // Error initializing auth
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final user = await SupabaseService.getUserById(uid);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      // Error loading user data
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await SupabaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserData(response.user!.id);
        _setLoading(false);
        return true;
      } else {
        _setError('Authentication failed');
        _setLoading(false);
        return false;
      }
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.message) {
        case 'Invalid login credentials':
          errorMessage = 'Invalid email or password';
          break;
        case 'Email not confirmed':
          errorMessage = 'Please confirm your email address';
          break;
        case 'Too many requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
      }
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      // Error signing out
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    if (_currentUser != null) {
      await _loadUserData(_currentUser!.id);
    }
  }
}
