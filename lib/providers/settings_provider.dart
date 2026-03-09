import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/secure_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SecureStorageService _storage;

  bool _hasApiKey = false;
  bool get hasApiKey => _hasApiKey;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _userName = 'Learning...';
  String get userName => _userName;

  String _userAvatar = '🍌';
  String get userAvatar => _userAvatar;

  SettingsProvider({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService() {
    _init();
  }

  Future<void> _init() async {
    _hasApiKey = await _storage.hasApiKey();
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? 'Learning...';
    _userAvatar = prefs.getString('user_avatar') ?? '🍌';
    notifyListeners();
  }

  Future<void> updateProfile(String name, String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_avatar', avatar);
    _userName = name;
    _userAvatar = avatar;
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    await _storage.saveApiKey(key);
    _hasApiKey = key.isNotEmpty;
    notifyListeners();
  }

  Future<void> clearApiKey() async {
    await _storage.deleteApiKey();
    _hasApiKey = false;
    notifyListeners();
  }

  Future<String?> getApiKey() => _storage.getApiKey();

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }
}
