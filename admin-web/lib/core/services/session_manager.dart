import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _adminSessionKey = 'admin_session';
  static const String _adminCredentialsKey = 'admin_credentials';

  // Cache admin session data
  static Future<void> cacheAdminSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminSessionKey, jsonEncode(userData));
  }

  // Cache admin credentials
  static Future<void> cacheAdminCredentials(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminCredentialsKey, email);
  }

  // Get cached admin session
  static Future<Map<String, dynamic>?> getAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString(_adminSessionKey);
    if (sessionData != null) {
      return jsonDecode(sessionData) as Map<String, dynamic>;
    }
    return null;
  }

  // Get cached admin credentials
  static Future<String?> getAdminCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminCredentialsKey);
  }

  // Clear admin session
  static Future<void> clearAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adminSessionKey);
    await prefs.remove(_adminCredentialsKey);
  }

  // Check if admin is logged in
  static Future<bool> isAdminLoggedIn() async {
    final session = await getAdminSession();
    return session != null;
  }

  // Get admin user ID
  static Future<String?> getAdminUserId() async {
    final session = await getAdminSession();
    return session?['id'];
  }

  // Get admin email
  static Future<String?> getAdminEmail() async {
    final session = await getAdminSession();
    return session?['email'];
  }

  // Get admin name
  static Future<String?> getAdminName() async {
    final session = await getAdminSession();
    return session?['name'];
  }

  // Restore admin session (placeholder - implement actual logic)
  static Future<bool> restoreAdminSession() async {
    // This is a placeholder implementation
    // In a real app, you would validate the admin credentials here
    final session = await getAdminSession();
    return session != null;
  }
}
