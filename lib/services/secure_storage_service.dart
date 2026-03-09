import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureStorageService {
  String get _keyApiKey {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    return 'gemini_api_key_$userId';
  }

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> getApiKey() => _storage.read(key: _keyApiKey);

  Future<void> saveApiKey(String apiKey) =>
      _storage.write(key: _keyApiKey, value: apiKey);

  Future<void> deleteApiKey() => _storage.delete(key: _keyApiKey);

  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}
