import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/session_manager.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  static const String _keyUserSession = 'cf_auth_user_session';
  static const String _keySavedUsername = 'cf_auth_saved_username';
  static const String _keySavedPassword = 'cf_auth_saved_password';
  static const String _keyRememberMe = 'cf_auth_remember_me';
  static const String _keyIsMarkupEnabled = 'cf_auth_is_markup_enabled';
  static const String _keyMarkupCategories = 'cf_auth_markup_categories';
  static const String _keyUserProfileData = 'cf_auth_user_profile_data';

  SharedPreferences? _prefs;

  AuthLocalDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) return _prefs;
    try {
      _prefs = await SharedPreferences.getInstance();
      return _prefs;
    } catch (_) {
      return null;
    }
  }

  /// Saves the active authenticated user profile to local session.
  Future<void> saveUserSession(UserModel user) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      final jsonStr = jsonEncode(user.toJson());
      await prefs.setString(_keyUserSession, jsonStr);
    } catch (_) {}
  }

  /// Retrieves the cached user session, or null if no active session exists.
  Future<UserModel?> getUserSession() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return null;
      final jsonStr = prefs.getString(_keyUserSession);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Persists credentials for auto-fill and quick-toggle actions.
  Future<void> saveCredentials(
    String username,
    String password, {
    bool remember = true,
  }) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      await prefs.setString(_keySavedUsername, username);
      if (remember) {
        await prefs.setString(_keySavedPassword, password);
      } else {
        await prefs.remove(_keySavedPassword);
      }
      await prefs.setBool(_keyRememberMe, remember);
    } catch (_) {}
  }

  /// Retrieves saved credentials.
  Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return {'username': null, 'password': null};
      final username = prefs.getString(_keySavedUsername);
      final password = prefs.getString(_keySavedPassword);
      return {
        'username': username,
        'password': password,
      };
    } catch (_) {
      return {'username': null, 'password': null};
    }
  }

  /// Retrieves whether 'Remember Me' is checked.
  Future<bool> getRememberMe() async {
    try {
      final prefs = await _getPrefs();
      return prefs?.getBool(_keyRememberMe) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Persists dealer markup toggle state.
  Future<void> saveMarkupState({
    required bool isEnabled,
    List<String> categories = const [],
  }) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      await prefs.setBool(_keyIsMarkupEnabled, isEnabled);
      if (categories.isNotEmpty) {
        await prefs.setStringList(_keyMarkupCategories, categories);
      }
    } catch (_) {}
  }

  /// Retrieves stored markup enabled state.
  Future<bool?> getMarkupState() async {
    try {
      final prefs = await _getPrefs();
      return prefs?.getBool(_keyIsMarkupEnabled);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves stored markup categories.
  Future<List<String>> getMarkupCategories() async {
    try {
      final prefs = await _getPrefs();
      return prefs?.getStringList(_keyMarkupCategories) ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Checks if an active user session exists in local storage.
  Future<bool> hasActiveSession() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return false;
      final jsonStr = prefs.getString(_keyUserSession);
      return jsonStr != null && jsonStr.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Clears active session upon logout.
  Future<void> clearSession({bool keepSavedUsername = false}) async {
    SessionManager.clearSession();
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      await prefs.remove(_keyUserSession);
      await prefs.remove(_keySavedPassword);
      await prefs.remove(_keyIsMarkupEnabled);
      await prefs.remove(_keyMarkupCategories);
      await prefs.remove(_keyUserProfileData);

      if (!keepSavedUsername) {
        await prefs.remove(_keySavedUsername);
        await prefs.remove(_keyRememberMe);
      }
    } catch (_) {}
  }

  /// Persists full profile response JSON.
  Future<void> saveProfileData(Map<String, dynamic> jsonMap) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      await prefs.setString(_keyUserProfileData, jsonEncode(jsonMap));
    } catch (_) {}
  }

  /// Retrieves stored profile response JSON.
  Future<Map<String, dynamic>?> getProfileData() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return null;
      final jsonStr = prefs.getString(_keyUserProfileData);
      if (jsonStr == null || jsonStr.isEmpty) return null;
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
