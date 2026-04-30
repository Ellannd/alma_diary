import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  bool _initialized = false;
  SharedPreferences? _prefs;

  Future<void> init() async {
    if (_initialized) return;
    
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  bool get isInitialized => _initialized;
  
  bool get isWeb => kIsWeb;

  Future<void> setString(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _prefs?.setString(key, value);
    }
  }

  Future<String?> getString(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _prefs?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } else {
      await _prefs?.setBool(key, value);
    }
  }

  Future<bool?> getBool(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    }
    return _prefs?.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } else {
      await _prefs?.setInt(key, value);
    }
  }

  Future<int?> getInt(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    }
    return _prefs?.getInt(key);
  }

  Future<void> remove(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _prefs?.remove(key);
    }
  }

  Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _prefs?.clear();
    }
  }

  Future<bool> containsKey(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    }
    return _prefs?.containsKey(key) ?? false;
  }
}