import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

const _trendingWords = ['Ephemeral', 'Resilience', 'Serendipity', 'Luminous'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  void _search(String word) {
    if (word.trim().isEmpty) return;
    _focusNode.unfocus();
    context.push('/word/${word.trim()}');
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  const SizedBox(width: 42),
                  Expanded(
                    child: Center(
                      child: Text(
                        'DeVocab',
                        style: TextStyle(
                          fontFamily: 'NotoSerifTC',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 26),
                    color: colorScheme.onSurface,
                    onPressed: () => context.go('/settings'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Image Embedding (附圖二)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimary.withOpacity(0.15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/your_image.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            color: kPrimary,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Hero title
                    Text(
                      '探索字彙的奧秘',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 36,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '輸入單字，開啟您的語言之旅。\n細味文字背後的深度與溫度。',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: kPrimary.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          filled: false,
                          prefixIcon: const Icon(Icons.search, color: kPrimary),
                          hintText: '搜尋單字、定義或例句...',
                          hintStyle: TextStyle(
                            fontFamily: 'NotoSansTC',
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Trending
                    Text(
                      '熱門搜尋趨勢',
                      style: AppTextStyles.label.copyWith(
                        color: kPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _trendingWords
                          .map((w) => _TrendingChip(
                                word: w,
                                onTap: () => _search(w),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _TrendingChip extends StatelessWidget {
  final String word;
  final VoidCallback onTap;
  const _TrendingChip({required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    return Material(
      color: isDark ? kSurfaceDark : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: kPrimary.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, size: 16,
                  color: kPrimary.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(
                word,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
