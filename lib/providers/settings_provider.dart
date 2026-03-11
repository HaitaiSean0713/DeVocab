import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/secure_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SecureStorageService _storage;

  bool _hasApiKey = false;
  bool get hasApiKey => _hasApiKey;

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
    _init();
  }

  Future<void> _init() async {
    _hasApiKey = await _storage.hasApiKey();
    final prefs = await SharedPreferences.getInstance();

    // Cloud sync logic: try fetching from Supabase user_metadata first
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && user.userMetadata != null) {
      _userName = user.userMetadata!['user_name'] ?? prefs.getString(_getUserNameKey()) ?? 'Learning...';
      _userAvatar = user.userMetadata!['user_avatar'] ?? prefs.getString(_getUserAvatarKey()) ?? '🍌';

      // Cache locally
      await prefs.setString(_getUserNameKey(), _userName);
      await prefs.setString(_getUserAvatarKey(), _userAvatar);
    } else {
      // Fallback
      _userName = prefs.getString(_getUserNameKey()) ?? 'Learning...';
      _userAvatar = prefs.getString(_getUserAvatarKey()) ?? '🍌';
    }

    notifyListeners();
  }

  Future<void> updateProfile(String name, String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getUserNameKey(), name);
    await prefs.setString(_getUserAvatarKey(), avatar);
    _userName = name;
    _userAvatar = avatar;
    notifyListeners();

    // Sync to Supabase cloud
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.auth.updateUser(UserAttributes(data: {
          'user_name': name,
          'user_avatar': avatar,
        }));
      } catch (e) {
        print('Failed to sync profile to cloud: $e');
      }
    }
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
}
