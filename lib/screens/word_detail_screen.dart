import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/word_data.dart';
import '../providers/word_provider.dart';
import '../providers/favorites_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordDetailScreen extends StatefulWidget {
  final String word;
  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  bool _isFavorited = false;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWord();
      _checkFavorite();
      _initTts();
    });
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakWord(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadWord() async {
    await context.read<WordProvider>().analyzeWord(widget.word);
  }

  Future<void> _checkFavorite() async {
    final fav = await context.read<FavoritesProvider>().isFavorite(widget.word);
    if (mounted) setState(() => _isFavorited = fav);
  }

  Future<void> _toggleFavorite(WordData data) async {
    await context.read<FavoritesProvider>().toggle(
          FavoriteWord(
            word: data.word,
            chineseMeaning: data.chineseMeaning,
            partOfSpeech: 'n.',
          ),
        );
    if (mounted) setState(() => _isFavorited = !_isFavorited);
  }

  Future<void> _reportError(String word) async {
    await context.read<WordProvider>().reportError(word);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('感謝回報！我們將審核此單字的分析結果。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: Consumer<WordProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                pinned: true,
                backgroundColor: kBackgroundLight.withOpacity(0.95),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text('單字分析'),
                actions: [
                  if (provider.wordData != null)
                    IconButton(
                      icon: const Icon(Icons.flag_outlined),
                      tooltip: '回報錯誤',
                      onPressed: () => _reportError(widget.word),
                    ),
                  if (provider.wordData != null)
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {
                        final data = provider.wordData!;
                        String text = '看這！我在 DeVocab 學到了「${data.word}」\\n';
                        text += '發音：${data.phonetic}\\n';
                        text += '意思：${data.chineseMeaning}\\n\\n';
                        for (var m in data.morphemes) {
                          text += '• ${m.form} (${m.type == 'prefix' ? '字首' : m.type == 'suffix' ? '字尾' : '字根'})：${m.chineseMeaning}\\n';
                        }
                        Share.share(text);
                      },
                    ),
                ],
              ),
              if (provider.state == WordQueryState.loading)
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: kPrimary),
                        const SizedBox(height: 20),
                        Text('AI 正在分析詞素...', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                )
              else if (provider.state == WordQueryState.error)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 56,
                                color: Colors.red.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.red.shade400),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (provider.suggestion != null)
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => WordDetailScreen(word: provider.suggestion!),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.search, size: 20),
                              label: Text('查詢「${provider.suggestion}」'),
                            )
                          else
                            ElevatedButton(
                              onPressed: _loadWord,
                              child: const Text('重試'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              else if (provider.wordData != null)
                _buildContent(provider.wordData!)
              else
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(WordData data) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Verified badge
          if (data.isVerified)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: kPrimary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 14, color: kPrimary),
                  const SizedBox(width: 4),
                  Text('已人工審核',
                      style: AppTextStyles.caption.copyWith(color: kPrimary)),
                ],
              ),
            ),
          if (data.isVerified) const SizedBox(height: 16),

          // Word header
          Text(
            data.word.isNotEmpty
                ? data.word[0].toUpperCase() + data.word.substring(1)
                : '',
            style: AppTextStyles.displayWord,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            data.phonetic,
            style: AppTextStyles.bodyLarge.copyWith(
              color: kPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            data.chineseMeaning,
            style: AppTextStyles.headingMedium.copyWith(
              color: const Color(0xFF5A5E5A),
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _speakWord(data.word),
                  icon: const Icon(Icons.volume_up_outlined, size: 20),
                  label: const Text('發音'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleFavorite(data),
                  icon: Icon(
                    _isFavorited ? Icons.bookmark : Icons.bookmark_outline,
                    size: 20,
                  ),
                  label: Text(_isFavorited ? '已收藏' : '收藏'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: const BorderSide(color: kPrimary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Morphemes section
          if (data.morphemes.isNotEmpty) ...[
            Text(
              '詞根拆解',
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFF8A8E8A),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...data.morphemes.map((m) => _MorphemeCard(morpheme: m)),
            const SizedBox(height: 32),
          ],

          // Example sentences
          if (data.examples.isNotEmpty) ...[
            Text(
              '例句用法',
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFF8A8E8A),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...data.examples.map((e) => _ExampleCard(
                  example: e,
                  keyword: data.word,
                )),
          ],

          // Synonyms Section
          if (data.synonyms.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '中文同意 / 同義詞',
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFF8A8E8A),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.synonyms.map((s) => Chip(
                label: Text(s),
                backgroundColor: kPrimary.withOpacity(0.1),
                side: BorderSide.none,
                labelStyle: const TextStyle(color: kPrimary),
              )).toList(),
            ),
          ],

          // Related Words Section
          if (data.relatedWords.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '相同字根字首字尾 / 關聯單字',
              style: AppTextStyles.label.copyWith(
                color: const Color(0xFF8A8E8A),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ...data.relatedWords.map((rw) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.link, size: 16, color: kPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rw,
                      style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF2A2E2A)),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ]),
      ),
    );
  }
}

class _MorphemeCard extends StatelessWidget {
  final MorphemeData morpheme;
  const _MorphemeCard({required this.morpheme});

  IconData _iconFor(String hint) {
    const map = {
      'eco': Icons.eco,
      'menu_book': Icons.menu_book,
      'science': Icons.science,
      'biotech': Icons.biotech,
      'psychology': Icons.psychology,
      'abc': Icons.abc,
    };
    return map[hint] ?? Icons.translate;
  }

  String get _typeLabel {
    switch (morpheme.type) {
      case 'prefix':
        return '字首';
      case 'suffix':
        return '字尾';
      default:
        return '字根';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLowConfidence = morpheme.confidence == 'low';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowConfidence
              ? Colors.orange.withOpacity(0.4)
              : kPrimary.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary.withOpacity(0.12),
            ),
            child: Icon(_iconFor(morpheme.iconHint), color: kPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(morpheme.form,
                        style: AppTextStyles.morphemeTitle),
                    if (isLowConfidence) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: '此詞素的拆解存在不確定性',
                        child: Icon(Icons.warning_amber_rounded,
                            size: 16, color: Colors.orange.shade400),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$_typeLabel：${morpheme.chineseMeaning}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF8A8E8A),
                  ),
                ),
                if (morpheme.origin.isNotEmpty)
                  Text(
                    morpheme.origin,
                    style: AppTextStyles.caption.copyWith(
                      color: kPrimary.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final ExampleSentence example;
  final String keyword;
  const _ExampleCard({required this.example, required this.keyword});

  List<TextSpan> _buildHighlighted(String text, String keyword) {
    final lower = text.toLowerCase();
    final lowerKey = keyword.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lower.indexOf(lowerKey, start);
      if (idx == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: AppTextStyles.bodyLarge.copyWith(
            color: const Color(0xFF2A2E2A),
            height: 1.6,
          ),
        ));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(
          text: text.substring(start, idx),
          style: AppTextStyles.bodyLarge.copyWith(
            color: const Color(0xFF2A2E2A),
            height: 1.6,
          ),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + keyword.length),
        style: AppTextStyles.bodyLarge.copyWith(
          color: kPrimary,
          fontWeight: FontWeight.w700,
          height: 1.6,
        ),
      ));
      start = idx + keyword.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: kPrimary.withOpacity(0.35),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: _buildHighlighted(example.english, keyword)),
          ),
          const SizedBox(height: 6),
          Text(
            example.chinese,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF8A8E8A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
