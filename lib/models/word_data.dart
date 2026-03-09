// lib/models/word_data.dart
class MorphemeData {
  final String form;
  final String type; // 'prefix' | 'root' | 'suffix'
  final String origin;
  final String chineseMeaning;
  final String confidence; // 'high' | 'medium' | 'low'
  final String iconHint;

  const MorphemeData({
    required this.form,
    required this.type,
    required this.origin,
    required this.chineseMeaning,
    required this.confidence,
    required this.iconHint,
  });

  factory MorphemeData.fromJson(Map<String, dynamic> json) => MorphemeData(
        form: json['form'] ?? '',
        type: json['type'] ?? 'root',
        origin: json['origin'] ?? '',
        chineseMeaning: json['chinese_meaning'] ?? '',
        confidence: json['confidence'] ?? 'high',
        iconHint: json['icon_hint'] ?? 'abc',
      );

  Map<String, dynamic> toJson() => {
        'form': form,
        'type': type,
        'origin': origin,
        'chinese_meaning': chineseMeaning,
        'confidence': confidence,
        'icon_hint': iconHint,
      };
}

class ExampleSentence {
  final String english;
  final String chinese;

  const ExampleSentence({required this.english, required this.chinese});

  factory ExampleSentence.fromJson(Map<String, dynamic> json) =>
      ExampleSentence(
        english: json['english'] ?? '',
        chinese: json['chinese'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'english': english,
        'chinese': chinese,
      };
}

class WordData {
  final String word;
  final String phonetic;
  final String chineseMeaning;
  final List<MorphemeData> morphemes;
  final List<ExampleSentence> examples;
  final List<String> synonyms;
  final List<String> relatedWords;
  final bool isCached;
  final bool isVerified;
  final String? error;
  final String? suggestion;

  const WordData({
    required this.word,
    required this.phonetic,
    required this.chineseMeaning,
    required this.morphemes,
    required this.examples,
    this.synonyms = const [],
    this.relatedWords = const [],
    this.isCached = false,
    this.isVerified = false,
    this.error,
    this.suggestion,
  });

  factory WordData.fromJson(Map<String, dynamic> json, {bool isCached = false, bool isVerified = false}) => WordData(
        word: json['word'] ?? '',
        phonetic: json['phonetic'] ?? '',
        chineseMeaning: json['chinese_meaning'] ?? '',
        morphemes: (json['morphemes'] as List<dynamic>? ?? [])
            .map((m) => MorphemeData.fromJson(m as Map<String, dynamic>))
            .toList(),
        examples: (json['examples'] as List<dynamic>? ?? [])
            .map((e) => ExampleSentence.fromJson(e as Map<String, dynamic>))
            .toList(),
        synonyms: (json['synonyms'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        relatedWords: (json['related_words'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        isCached: isCached,
        isVerified: isVerified,
        error: json['error'],
        suggestion: json['suggestion'],
      );

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'chinese_meaning': chineseMeaning,
        'morphemes': morphemes.map((m) => m.toJson()).toList(),
        'examples': examples.map((e) => e.toJson()).toList(),
        'synonyms': synonyms,
        'related_words': relatedWords,
      };
}

class FavoriteWord {
  final String word;
  final String chineseMeaning;
  final String partOfSpeech;

  const FavoriteWord({
    required this.word,
    required this.chineseMeaning,
    required this.partOfSpeech,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'chinese_meaning': chineseMeaning,
        'part_of_speech': partOfSpeech,
      };

  factory FavoriteWord.fromJson(Map<String, dynamic> json) => FavoriteWord(
        word: json['word'] ?? '',
        chineseMeaning: json['chinese_meaning'] ?? '',
        partOfSpeech: json['part_of_speech'] ?? '',
      );
}
