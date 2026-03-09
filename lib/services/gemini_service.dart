import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_data.dart';

class GeminiParseException implements Exception {
  final String message;
  const GeminiParseException(this.message);
  @override
  String toString() => 'GeminiParseException: $message';
}

class GeminiService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  final String apiKey;
  GeminiService({required this.apiKey});

  String _buildPrompt(String word) => '''
你是專業的英語字源學家 (etymologist)。
分析單字 "$word"，嚴格按照以下 JSON 格式回傳，不要任何多餘文字、不要 markdown 代碼塊：
{
  "word": "$word",
  "phonetic": "IPA 音標，如 /baɪˈɒl.ə.dʒi/",
  "chinese_meaning": "最精確的中文詞義",
  "morphemes": [
    {
      "form": "詞素形式，如 bio-",
      "type": "prefix 或 root 或 suffix",
      "origin": "語源，如 Greek 或 Latin",
      "chinese_meaning": "該詞素的中文意義",
      "confidence": "high 或 medium 或 low",
      "icon_hint": "最接近的 Material Icons 名稱，如 eco、menu_book、science"
    }
  ],
  "examples": [
    {
      "english": "含有 $word 的完整例句",
      "chinese": "例句中文翻譯"
    },
    {
      "english": "第二個例句",
      "chinese": "第二個例句中文翻譯"
    },
      "english": "第三個例句",
      "chinese": "第三個例句中文翻譯"
    }
  ],
  "synonyms": [
    "同義詞1",
    "同義詞2"
  ],
  "related_words": [
    "同字根/同字尾單字1 (中文意思)",
    "同字根/同字尾單字2 (中文意思)"
  ]
}

規則：
1. morphemes 陣列按照在單字中出現的順序排列（字首 → 字根 → 字尾）
2. 若該單字無法拆解詞素（如代詞、連接詞、短詞），morphemes 回傳空陣列 []
3. confidence 評估標準：high=學界公認、medium=普遍接受但有爭議、low=推測性
4. icon_hint 使用 Material Symbols 的圖示名稱，選擇語意相關的
5. synonyms 請提供 2~3 個意思相近的英文單字
6. related_words 請提供 2~3 個具有共同字首字根的衍生字或相關字，並附帶簡單中文解釋
7. 如果 "$word" 拼字錯誤或根本不存在，不要回傳上述格式，請回傳這兩種可能之一的 JSON：
   若能推測正確單字：{ "error": "not_found", "suggestion": "正確拼寫單字" }
   若無法推測：{ "error": "not_found" }
8. 嚴格只回傳 JSON，不要任何說明文字
''';

  Future<WordData> analyzeWord(String word) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': _buildPrompt(word.trim().toLowerCase())}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 1,
          'topP': 0.95,
          'maxOutputTokens': 2048,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw GeminiParseException(
          'API error ${response.statusCode}: ${response.body}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = responseJson['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw const GeminiParseException('No candidates in response');
    }

    final content = candidates[0]['content']['parts'][0]['text'] as String;

    // Strip potential markdown code blocks
    String cleaned = content.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'```json?\n?'), '').replaceAll('```', '').trim();
    }

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw GeminiParseException('JSON parse failed: $e\nContent: $cleaned');
    }

    // Ensure word field
    parsed['word'] = word.trim();

    return WordData.fromJson(parsed);
  }
}
