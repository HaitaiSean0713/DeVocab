import 'package:flutter/foundation.dart';
import '../models/word_data.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service;

  List<FavoriteWord> _favorites = [];
  List<FavoriteWord> get favorites => _favorites;

  String _searchQuery = '';
  List<FavoriteWord> get filtered => _searchQuery.isEmpty
      ? _favorites
      : _favorites
          .where((f) =>
              f.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              f.chineseMeaning.contains(_searchQuery))
          .toList();

  FavoritesProvider({FavoritesService? service})
      : _service = service ?? FavoritesService() {
    load();
  }

  Future<void> load() async {
    _favorites = await _service.getFavorites();
    notifyListeners();
  }

  Future<bool> isFavorite(String word) => _service.isFavorite(word);

  Future<void> toggle(FavoriteWord word) async {
    if (await _service.isFavorite(word.word)) {
      await _service.removeFavorite(word.word);
    } else {
      await _service.addFavorite(word);
    }
    await load();
  }

  Future<void> remove(String word) async {
    await _service.removeFavorite(word);
    await load();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _service.clearAll();
    await load();
  }
}
