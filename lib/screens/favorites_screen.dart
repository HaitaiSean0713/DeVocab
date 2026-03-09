import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/word_data.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                          color: kPrimary.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () => context.go('/'),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '我的收藏',
                        style: TextStyle(
                          fontFamily: 'NotoSerifTC',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: kPrimary.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (q) =>
                    context.read<FavoritesProvider>().search(q),
                style: AppTextStyles.bodyMedium,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: kPrimary, size: 20),
                  hintText: '搜尋已收藏單字...',
                  hintStyle: TextStyle(
                    color: Color(0xFFA0A4A0),
                    fontFamily: 'NotoSansTC',
                    fontSize: 14,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          // List
          Expanded(
            child: Consumer<FavoritesProvider>(
              builder: (context, provider, _) {
                final items = provider.filtered;
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          '還沒有收藏的單字',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, _x) => Divider(
                    color: kPrimary.withOpacity(0.1),
                    height: 1,
                  ),
                  itemBuilder: (context, i) {
                    if (i == items.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 36, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text(
                              '這就是您的清單終點',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey.shade400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return _FavoriteItem(
                      word: items[i],
                      onTap: () =>
                          context.push('/word/${items[i].word}'),
                      onRemove: () =>
                          provider.remove(items[i].word),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final FavoriteWord word;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _FavoriteItem(
      {required this.word, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word[0].toUpperCase() + word.word.substring(1),
                    style: const TextStyle(
                      fontFamily: 'NotoSerifTC',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1C1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.chineseMeaning,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF8A8E8A),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.star, color: kPrimary, size: 26),
              onPressed: onRemove,
            ),
            const Icon(Icons.chevron_right,
                color: Color(0xFFCCCCCC), size: 22),
          ],
        ),
      ),
    );
  }
}
