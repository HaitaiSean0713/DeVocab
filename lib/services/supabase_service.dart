import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word_data.dart';

class SupabaseService {
  static const _table = 'vocabulary_cache';

  SupabaseClient get _client => Supabase.instance.client;

  bool get isConfigured {
    try {
      _client;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<WordData?> getFromCache(String word) async {
    if (!isConfigured) return null;
    try {
      final res = await _client
          .from(_table)
          .select('data, is_verified, search_count')
          .eq('word', word.toLowerCase())
          .maybeSingle();

      if (res == null) return null;

      final data = res['data'];
      Map<String, dynamic> json;
      if (data is String) {
        json = jsonDecode(data) as Map<String, dynamic>;
      } else {
        json = Map<String, dynamic>.from(data as Map);
      }
      json['word'] = word;

      return WordData.fromJson(
        json,
        isCached: true,
        isVerified: res['is_verified'] as bool? ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToCache(String word, WordData data) async {
    if (!isConfigured) return;
    try {
      await _client.from(_table).upsert({
        'word': word.toLowerCase(),
        'data': jsonEncode(data.toJson()),
        'search_count': 1,
        'is_verified': false,
        'reported_count': 0,
      }, onConflict: 'word');
    } catch (_) {}
  }

  Future<void> incrementSearchCount(String word) async {
    if (!isConfigured) return;
    try {
      await _client.rpc('increment_search_count', params: {'p_word': word.toLowerCase()});
    } catch (_) {}
  }

  Future<void> reportError(String word) async {
    if (!isConfigured) return;
    try {
      // Increment reported_count; if >= 3 clear cache entry
      final res = await _client
          .from(_table)
          .select('reported_count, is_verified')
          .eq('word', word.toLowerCase())
          .maybeSingle();

      if (res == null) return;
      final isVerified = res['is_verified'] as bool? ?? false;
      if (isVerified) return; // 已人工確認，不受回報影響

      final currentCount = (res['reported_count'] as int? ?? 0) + 1;
      if (currentCount >= 3) {
        // Auto-clear cache, force re-generation
        await _client.from(_table).delete().eq('word', word.toLowerCase());
      } else {
        await _client
            .from(_table)
            .update({'reported_count': currentCount}).eq('word', word.toLowerCase());
      }
    } catch (_) {}
  }
}
