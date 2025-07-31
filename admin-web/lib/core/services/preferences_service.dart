import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static SharedPreferences? _prefs;
  static final Map<String, dynamic> _fallbackStorage = {};

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // SharedPreferences not available, using fallback storage
      _prefs = null;
    }
  }

  static SharedPreferences? get instance => _prefs;

  // User preferences
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguageCode = 'language_code';

  // Helper methods for fallback storage
  static String? _getString(String key) {
    if (_prefs != null) {
      return _prefs!.getString(key);
    }
    return _fallbackStorage[key] as String?;
  }

  static bool? _getBool(String key) {
    if (_prefs != null) {
      return _prefs!.getBool(key);
    }
    return _fallbackStorage[key] as bool?;
  }

  static Future<bool> _setString(String key, String value) async {
    if (_prefs != null) {
      return await _prefs!.setString(key, value);
    }
    _fallbackStorage[key] = value;
    return true;
  }

  static Future<bool> _setBool(String key, bool value) async {
    if (_prefs != null) {
      return await _prefs!.setBool(key, value);
    }
    _fallbackStorage[key] = value;
    return true;
  }

  static Future<bool> _remove(String key) async {
    if (_prefs != null) {
      return await _prefs!.remove(key);
    }
    _fallbackStorage.remove(key);
    return true;
  }

  // User data getters/setters
  static String? get userId => _getString(_keyUserId);
  static set userId(String? value) =>
      value != null ? _setString(_keyUserId, value) : _remove(_keyUserId);

  static String? get userEmail => _getString(_keyUserEmail);
  static set userEmail(String? value) =>
      value != null ? _setString(_keyUserEmail, value) : _remove(_keyUserEmail);

  static String? get userName => _getString(_keyUserName);
  static set userName(String? value) =>
      value != null ? _setString(_keyUserName, value) : _remove(_keyUserName);

  static bool get isFirstLaunch => _getBool(_keyIsFirstLaunch) ?? true;
  static set isFirstLaunch(bool value) => _setBool(_keyIsFirstLaunch, value);

  static String get themeMode => _getString(_keyThemeMode) ?? 'system';
  static set themeMode(String value) => _setString(_keyThemeMode, value);

  static String get languageCode => _getString(_keyLanguageCode) ?? 'en';
  static set languageCode(String value) => _setString(_keyLanguageCode, value);

  // Clear all user data
  static Future<void> clearUserData() async {
    await _remove(_keyUserId);
    await _remove(_keyUserEmail);
    await _remove(_keyUserName);
  }
}
