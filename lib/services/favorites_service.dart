import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_data.dart';

class FavoritesService {
  static const _key = 'favorites';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<FavoriteWord>> getFavorites() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => FavoriteWord.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isFavorite(String word) async {
    final favorites = await getFavorites();
    return favorites.any((f) => f.word.toLowerCase() == word.toLowerCase());
  }

  Future<void> addFavorite(FavoriteWord word) async {
    final prefs = await _prefs;
    final favorites = await getFavorites();
    if (!favorites.any((f) => f.word.toLowerCase() == word.word.toLowerCase())) {
      favorites.insert(0, word);
      await prefs.setStringList(
          _key, favorites.map((f) => jsonEncode(f.toJson())).toList());
    }
  }

  Future<void> removeFavorite(String word) async {
    final prefs = await _prefs;
    final favorites = await getFavorites();
    favorites.removeWhere((f) => f.word.toLowerCase() == word.toLowerCase());
    await prefs.setStringList(
        _key, favorites.map((f) => jsonEncode(f.toJson())).toList());
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_key);
  }
}
