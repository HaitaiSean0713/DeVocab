import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  String _getUserNameKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    return 'user_name_$userId';
  }

  String _getUserAvatarKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    return 'user_avatar_$userId';
  }

  SettingsProvider({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService() {
    load();
  }

  Future<void> load() async {
    _hasApiKey = await _storage.hasApiKey();
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_getUserNameKey()) ?? 'Learning...';
    _userAvatar = prefs.getString(_getUserAvatarKey()) ?? '🍌';
    notifyListeners();
  }

  Future<void> updateProfile(String name, String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getUserNameKey(), name);
    await prefs.setString(_getUserAvatarKey(), avatar);
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
