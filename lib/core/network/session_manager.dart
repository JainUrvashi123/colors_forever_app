import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _cookieStorageKey = 'cf_auth_session_cookie';
  static final Map<String, String> _cookies = {};
  static String? userId;
  static String? vdUserId = '25';
  static String? vdGroupId = '4';
  static String? username;
  static String? password;

  static Future<bool> Function()? reauthenticate;

  static String? get sessionCookie => _buildCookieHeader();

  static String _buildCookieHeader() {
    if (_cookies.isEmpty) return '';
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  static Future<void> loadSessionCookie() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookieStr = prefs.getString(_cookieStorageKey);
      if (cookieStr != null && cookieStr.isNotEmpty) {
        _parseAndMergeCookieString(cookieStr);
      }
    } catch (_) {}
  }

  static Future<void> _saveSessionCookie() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final header = _buildCookieHeader();
      if (header.isNotEmpty) {
        await prefs.setString(_cookieStorageKey, header);
      } else {
        await prefs.remove(_cookieStorageKey);
      }
    } catch (_) {}
  }

  static void _parseAndMergeCookieString(String rawCookieHeader) {
    final parts = rawCookieHeader.split(RegExp(r'[,;]'));
    for (var part in parts) {
      part = part.trim();
      if (part.isEmpty) continue;
      final eqIdx = part.indexOf('=');
      if (eqIdx <= 0) continue;

      final key = part.substring(0, eqIdx).trim();
      final val = part.substring(eqIdx + 1).trim();
      final lowerKey = key.toLowerCase();

      if (lowerKey == 'expires' ||
          lowerKey == 'max-age' ||
          lowerKey == 'path' ||
          lowerKey == 'domain' ||
          lowerKey == 'samesite' ||
          lowerKey == 'secure' ||
          lowerKey == 'httponly') {
        continue;
      }

      _cookies[key] = val;
    }
  }

  static void updateCookieFromResponse(Map<String, String> headers) {
    final rawCookie = headers['set-cookie'] ?? headers['Set-Cookie'];
    if (rawCookie != null && rawCookie.isNotEmpty) {
      _parseAndMergeCookieString(rawCookie);
      debugPrint('SessionManager: cookie set => ${_buildCookieHeader()}');
      _saveSessionCookie();
    }
  }

  static void setCookie(String? cookie) {
    _cookies.clear();
    if (cookie != null && cookie.isNotEmpty) {
      _parseAndMergeCookieString(cookie);
    }
    _saveSessionCookie();
  }

  static Map<String, String> getHeaders({bool isJson = true}) {
    final map = <String, String>{
      'Accept': 'application/json, text/javascript, */*; q=0.01',
      if (isJson) 'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'User-Agent': 'Mozilla/5.0 (Mobile; ColorsForeverApp)',
    };
    final header = _buildCookieHeader();
    if (header.isNotEmpty) {
      map['Cookie'] = header;
    }
    return map;
  }

  static void clearSession() {
    _cookies.clear();
    userId = null;
    vdUserId = '25';
    vdGroupId = '4';
    username = null;
    password = null;
    _saveSessionCookie();
  }
}
