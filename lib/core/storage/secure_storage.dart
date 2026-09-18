import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  StorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _keyToken = 'access_token';
  static const String _keyUserId = 'user_id';
  static const String _keySelectedCity = 'selected_city';
  static const String _keyCustomBaseUrl = 'custom_base_url';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // User details
  Future<void> saveUserId(String id) async {
    await _prefs?.setString(_keyUserId, id);
  }

  String? getUserId() {
    return _prefs?.getString(_keyUserId);
  }

  // Selected city filter
  Future<void> saveSelectedCity(String city) async {
    await _prefs?.setString(_keySelectedCity, city);
  }

  String getSelectedCity() {
    return _prefs?.getString(_keySelectedCity) ?? 'Bangalore';
  }

  // Custom Base URL (for switching environments)
  Future<void> saveCustomBaseUrl(String url) async {
    await _prefs?.setString(_keyCustomBaseUrl, url);
  }

  String? getCustomBaseUrl() {
    return _prefs?.getString(_keyCustomBaseUrl);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}
