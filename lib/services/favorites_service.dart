import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word_data.dart';

class FavoritesService {
  String _getKey() {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    return 'favorites_$userId';
  }

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();
  final _auth = Supabase.instance.client.auth;

  Future<List<FavoriteWord>> getFavorites() async {
    final prefs = await _prefs;

    // 優先從 Supabase user_metadata 讀取 (Cloud Sync)
    final user = _auth.currentUser;
    if (user != null && user.userMetadata != null && user.userMetadata!['favorites'] != null) {
      try {
        final List<dynamic> metaFavs = user.userMetadata!['favorites'];
        final cloudFavorites = metaFavs
            .map((e) => FavoriteWord.fromJson(e as Map<String, dynamic>))
            .toList();

        // 快取到本地
        await prefs.setStringList(
            _getKey(), cloudFavorites.map((f) => jsonEncode(f.toJson())).toList());
        return cloudFavorites;
      } catch (e) {
        print('Error parsing cloud favorites: $e');
      }
    }

    // 若雲端無資料或尚未登入，回退到本地儲存
    final localRaw = prefs.getStringList(_getKey()) ?? [];
    return localRaw
        .map((s) => FavoriteWord.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isFavorite(String word) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.word.toLowerCase() == word.toLowerCase());
  }

  Future<void> _syncToCloud(List<FavoriteWord> favorites) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final favData = favorites.map((f) => f.toJson()).toList();
        await _auth.updateUser(UserAttributes(data: {'favorites': favData}));
      } catch (e) {
        print('Failed to sync favorites to cloud: $e');
      }
    }
  }

  Future<void> addFavorite(FavoriteWord word) async {
    final prefs = await _prefs;
    final favorites = await getFavorites();
    if (!favorites.any((f) => f.word.toLowerCase() == word.word.toLowerCase())) {
      favorites.insert(0, word);
      await prefs.setStringList(
          _getKey(), favorites.map((f) => jsonEncode(f.toJson())).toList());
      await _syncToCloud(favorites);
    }
  }

  Future<void> removeFavorite(String word) async {
    final prefs = await _prefs;
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.word.toLowerCase() == word.toLowerCase());
    await prefs.setStringList(
        _getKey(), favorites.map((f) => jsonEncode(f.toJson())).toList());
    await _syncToCloud(favorites);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_getKey());
    await _syncToCloud([]);
  }
}
