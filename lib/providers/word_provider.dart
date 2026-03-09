import 'package:flutter/foundation.dart';
import '../models/word_data.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../services/secure_storage_service.dart';

enum WordQueryState { idle, loading, success, error }

class WordProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  final SecureStorageService _storageService;

  WordProvider({
    SupabaseService? supabaseService,
    SecureStorageService? storageService,
  })  : _supabaseService = supabaseService ?? SupabaseService(),
        _storageService = storageService ?? SecureStorageService();

  WordQueryState _state = WordQueryState.idle;
  WordQueryState get state => _state;

  WordData? _wordData;
  WordData? get wordData => _wordData;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String? _suggestion;
  String? get suggestion => _suggestion;

  final bool _isFavorited = false;
  bool get isFavorited => _isFavorited;

  Future<WordData?> analyzeWord(String word) async {
    if (word.trim().isEmpty) return null;

    _state = WordQueryState.loading;
    _wordData = null;
    _errorMessage = '';
    _suggestion = null;
    notifyListeners();

    try {
      // 1. Cache-first: check Supabase
      final cached = await _supabaseService.getFromCache(word.trim().toLowerCase());
      if (cached != null) {
        _wordData = cached;
        _state = WordQueryState.success;
        notifyListeners();
        // Async increment count
        _supabaseService.incrementSearchCount(word.trim().toLowerCase());
        return _wordData;
      }

      // 2. Fallback: Gemini API
      final apiKey = await _storageService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        _errorMessage = '請先設定 Gemini API Key';
        _state = WordQueryState.error;
        notifyListeners();
        return null;
      }

      final gemini = GeminiService(apiKey: apiKey);
      final result = await gemini.analyzeWord(word.trim());

      if (result.error == 'not_found') {
        _state = WordQueryState.error;
        if (result.suggestion != null && result.suggestion!.isNotEmpty) {
          _suggestion = result.suggestion;
          _errorMessage = '單字拼寫錯誤。您要找的是不是：「${result.suggestion}」？';
        } else {
          _errorMessage = '單字拼寫錯誤。';
        }
        notifyListeners();
        return null;
      }

      // 3. Save to cache
      await _supabaseService.saveToCache(word.trim().toLowerCase(), result);

      _wordData = result;
      _state = WordQueryState.success;
      notifyListeners();
      return _wordData;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = WordQueryState.error;
      notifyListeners();
      return null;
    }
  }

  Future<void> reportError(String word) async {
    await _supabaseService.reportError(word.toLowerCase());
  }

  void reset() {
    _state = WordQueryState.idle;
    _wordData = null;
    _errorMessage = '';
    _suggestion = null;
    notifyListeners();
  }
}
