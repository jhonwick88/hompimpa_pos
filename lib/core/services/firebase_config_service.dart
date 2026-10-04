import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseConfigService {
  static const String _keyApiKey = 'firebase_api_key';
  static const String _keyAppId = 'firebase_app_id';
  static const String _keyProjectId = 'firebase_project_id';
  static const String _keyMessagingSenderId = 'firebase_messaging_sender_id';
  static const String _keyStorageBucket = 'firebase_storage_bucket';
  static const String _keyAuthDomain = 'firebase_auth_domain';
  static const String _keyIsCustomConfig = 'firebase_is_custom_config';

  /// Mendapatkan instance SharedPreferences
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Mengecek apakah ada konfigurasi custom yang tersimpan
  static Future<bool> hasCustomConfig() async {
    try {
      final p = await _prefs;
      final isCustom = p.getBool(_keyIsCustomConfig) ?? false;
      final apiKey = p.getString(_keyApiKey);
      final projectId = p.getString(_keyProjectId);
      return isCustom && apiKey != null && apiKey.isNotEmpty && projectId != null && projectId.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking custom Firebase config: $e');
      return false;
    }
  }

  /// Membaca konfigurasi custom dan mengubahnya menjadi FirebaseOptions
  static Future<FirebaseOptions?> getCustomOptions() async {
    try {
      final p = await _prefs;
      final apiKey = p.getString(_keyApiKey);
      final appId = p.getString(_keyAppId);
      final projectId = p.getString(_keyProjectId);
      final messagingSenderId = p.getString(_keyMessagingSenderId);
      final storageBucket = p.getString(_keyStorageBucket);
      final authDomain = p.getString(_keyAuthDomain);

      if (apiKey == null || apiKey.isEmpty || projectId == null || projectId.isEmpty) {
        return null;
      }

      return FirebaseOptions(
        apiKey: apiKey,
        appId: appId ?? '1:1234567890:web:abcdef',
        messagingSenderId: messagingSenderId ?? '1234567890',
        projectId: projectId,
        storageBucket: (storageBucket != null && storageBucket.isNotEmpty)
            ? storageBucket
            : '$projectId.firebasestorage.app',
        authDomain: (authDomain != null && authDomain.isNotEmpty)
            ? authDomain
            : '$projectId.firebaseapp.com',
      );
    } catch (e) {
      debugPrint('Error getting custom Firebase options: $e');
      return null;
    }
  }

  /// Membaca raw configuration map untuk ditampilkan di form
  static Future<Map<String, String>> getRawConfig() async {
    final p = await _prefs;
    return {
      'apiKey': p.getString(_keyApiKey) ?? '',
      'appId': p.getString(_keyAppId) ?? '',
      'projectId': p.getString(_keyProjectId) ?? '',
      'messagingSenderId': p.getString(_keyMessagingSenderId) ?? '',
      'storageBucket': p.getString(_keyStorageBucket) ?? '',
      'authDomain': p.getString(_keyAuthDomain) ?? '',
    };
  }

  /// Menyimpan konfigurasi custom
  static Future<void> saveConfig({
    required String apiKey,
    required String appId,
    required String projectId,
    required String messagingSenderId,
    String? storageBucket,
    String? authDomain,
  }) async {
    final p = await _prefs;
    await p.setString(_keyApiKey, apiKey.trim());
    await p.setString(_keyAppId, appId.trim());
    await p.setString(_keyProjectId, projectId.trim());
    await p.setString(_keyMessagingSenderId, messagingSenderId.trim());
    await p.setString(_keyStorageBucket, (storageBucket ?? '').trim());
    await p.setString(_keyAuthDomain, (authDomain ?? '').trim());
    await p.setBool(_keyIsCustomConfig, true);
  }

  /// Menghapus konfigurasi custom (reset ke default)
  static Future<void> clearConfig() async {
    final p = await _prefs;
    await p.remove(_keyApiKey);
    await p.remove(_keyAppId);
    await p.remove(_keyProjectId);
    await p.remove(_keyMessagingSenderId);
    await p.remove(_keyStorageBucket);
    await p.remove(_keyAuthDomain);
    await p.setBool(_keyIsCustomConfig, false);
  }

  /// Smart Parser: Mengekstrak key-value dari teks snippet Firebase Console (JS Object / JSON)
  /// Contoh input yang didukung:
  /// 1. const firebaseConfig = { apiKey: "AIza...", projectId: "my-pos", ... };
  /// 2. { "apiKey": "AIza...", "projectId": "my-pos" }
  /// 3. Baris biasa: apiKey=AIza... atau apiKey: AIza...
  static Map<String, String> parseSnippet(String text) {
    final Map<String, String> result = {};
    if (text.trim().isEmpty) return result;

    String cleanText = text.trim();

    // 1. Coba parse sebagai JSON murni
    try {
      if (cleanText.startsWith('{') && cleanText.endsWith('}')) {
        final decoded = json.decode(cleanText);
        if (decoded is Map) {
          decoded.forEach((key, value) {
            result[key.toString()] = value.toString();
          });
          return _normalizeKeys(result);
        }
      }
    } catch (_) {}

    // 2. Regex parser untuk JS object snippet dari Firebase Console
    final keys = [
      'apiKey',
      'authDomain',
      'projectId',
      'storageBucket',
      'messagingSenderId',
      'appId',
      'measurementId'
    ];

    for (final key in keys) {
      // Pola: key: "value" atau "key": "value" atau key: 'value'
      final regExp = RegExp(
        '''['"]?$key['"]?\\s*[:=]\\s*['"]([^'"]+)['"]''',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(cleanText);
      if (match != null && match.groupCount >= 1) {
        result[key] = match.group(1)!.trim();
      }
    }

    return _normalizeKeys(result);
  }

  static Map<String, String> _normalizeKeys(Map<String, String> raw) {
    final Map<String, String> normalized = {};
    raw.forEach((k, v) {
      final lowerKey = k.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (lowerKey == 'apikey') {
        normalized['apiKey'] = v;
      } else if (lowerKey == 'appid') {
        normalized['appId'] = v;
      } else if (lowerKey == 'projectid') {
        normalized['projectId'] = v;
      } else if (lowerKey == 'messagingsenderid' || lowerKey == 'senderid') {
        normalized['messagingSenderId'] = v;
      } else if (lowerKey == 'storagebucket') {
        normalized['storageBucket'] = v;
      } else if (lowerKey == 'authdomain') {
        normalized['authDomain'] = v;
      }
    });
    return normalized;
  }
}
