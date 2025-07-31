import '../models/user_model.dart';
import 'session_manager.dart';
import 'supabase_service.dart';

class AdminLoginService {
  /// Login as admin and cache session
  static Future<bool> loginAsAdmin(String email, String password) async {
    try {
      // Sign in with Supabase Auth
      final response = await SupabaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return false;
      }

      // Get user data from database
      User? userData;
      try {
        userData = await SupabaseService.getUserById(response.user!.id);

        if (userData == null) {
          return false;
        }
      } catch (e) {
        return false;
      }

      // Check if user has admin access (admin, travelAgent, editor, contentEditor)
      if (!_hasAdminAccess(userData)) {
        await SupabaseService.signOut();
        return false;
      }

      // Cache admin session
      await SessionManager.cacheAdminSession(userData.toSupabase());
      await SessionManager.cacheAdminCredentials(email);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has admin access (admin, travelAgent, editor, contentEditor)
  static bool _hasAdminAccess(User user) {
    final hasAdmin = user.hasRole(UserRole.admin);
    final hasTravelAgent = user.hasRole(UserRole.travelAgent);
    final hasEditor = user.hasRole(UserRole.editor);
    final hasContentEditor = user.hasRole(UserRole.contentEditor);

    return hasAdmin || hasTravelAgent || hasEditor || hasContentEditor;
  }

  /// Check if current user has admin access
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final currentUser = SupabaseService.getCurrentUser();
      if (currentUser == null) return false;

      final userData = await SupabaseService.getUserById(currentUser.id);
      if (userData == null) return false;

      return _hasAdminAccess(userData);
    } catch (e) {
      return false;
    }
  }

  /// Get current admin user data
  static Future<User?> getCurrentAdminUser() async {
    try {
      final currentUser = SupabaseService.getCurrentUser();
      if (currentUser == null) return null;

      final userData = await SupabaseService.getUserById(currentUser.id);
      if (userData == null) return null;

      return _hasAdminAccess(userData) ? userData : null;
    } catch (e) {
      return null;
    }
  }
}
