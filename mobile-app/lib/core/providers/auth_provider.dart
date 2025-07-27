import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../services/preferences_service.dart';

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
      print('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final user = await SupabaseService.getUserById(userId);
      if (user != null) {
        _currentUser = user;
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

      final response = await SupabaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        await _loadUserData(user.id);
        await _saveUserToPreferences(user);
      }

      _setLoading(false);
      return user != null;
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.message) {
        case 'Invalid login credentials':
          errorMessage = 'Invalid email or password';
          break;
        case 'Email not confirmed':
          errorMessage = 'Please confirm your email address';
          break;
        case 'User not found':
          errorMessage = 'No account found with this email';
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

      final response = await SupabaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      final user = response.user;
      if (user != null) {
        // Create user profile in database
        final userModel = User(
          id: user.id,
          email: user.email!,
          name: name,
          photoUrl: user.userMetadata?['photo_url'],
          roles: [UserRole.traveler],
          isActive: true,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          profile: {},
        );

        // Insert user into database
        await Supabase.instance.client
            .from('users')
            .insert(userModel.toSupabase());

        _currentUser = userModel;
        await _saveUserToPreferences(user);
      }

      _setLoading(false);
      return user != null;
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.message) {
        case 'User already registered':
          errorMessage = 'An account already exists with this email';
          break;
        case 'Invalid email':
          errorMessage = 'Invalid email address';
          break;
        case 'Password should be at least 6 characters':
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

      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.message) {
        case 'Invalid email':
          errorMessage = 'Invalid email address';
          break;
        case 'User not found':
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

      await SupabaseService.signOut();

      _currentUser = null;
      await PreferencesService.clearUserData();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> _saveUserToPreferences(dynamic user) async {
    try {
      PreferencesService.userId = user.id;
      PreferencesService.userEmail = user.email;
      PreferencesService.userName = user.userMetadata?['name'] ?? 'User';
    } catch (e) {
      print('Error saving user to preferences: $e');
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    String? photoUrl,
    Map<String, dynamic>? profile,
  }) async {
    try {
      _setLoading(true);

      final currentUser = SupabaseService.getCurrentUser();
      if (currentUser == null) {
        _setError('No user logged in');
        _setLoading(false);
        return false;
      }

      final updates = <String, dynamic>{};
      if (name != null) {
        updates['name'] = name;
      }
      if (photoUrl != null) {
        updates['photo_url'] = photoUrl;
      }
      if (profile != null) {
        updates['profile'] = profile;
      }

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();

        await SupabaseService.updateUserProfile(
          userId: currentUser.id,
          updates: updates,
        );

        await _loadUserData(currentUser.id);
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
