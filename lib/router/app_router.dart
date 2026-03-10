import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/api_key_screen.dart';
import '../screens/home_screen.dart';
import '../screens/word_detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/settings_screen.dart';
import '../services/secure_storage_service.dart';

class AppRouter {
  static final SecureStorageService _storage = SecureStorageService();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: _guard,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/setup-api',
        name: 'setup-api',
        pageBuilder: (context, state) => _fadeTransition(
          state,
          const ApiKeyScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FavoritesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/word/:word',
        name: 'word-detail',
        pageBuilder: (context, state) {
          final word = state.pathParameters['word'] ?? '';
          return _slideTransition(
            state,
            WordDetailScreen(word: word),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );

  static Future<String?> _guard(BuildContext context, GoRouterState state) async {
    final session = Supabase.instance.client.auth.currentSession;
    final hasKey = await _storage.hasApiKey();
    final currentPath = state.uri.path;

    final isAuthPage = currentPath == '/login';

    // 1. Not logged in: must go to /login
    if (session == null) {
      return isAuthPage ? null : '/login';
    }

    // 2. Logged in, but at auth page: go forward
    if (isAuthPage) {
      return hasKey ? '/' : '/setup-api';
    }

    // 3. Logged in, no API key: must go to /setup-api
    if (!hasKey && currentPath != '/setup-api') {
      return '/setup-api';
    }

    return null;
  }

  static CustomTransitionPage _fadeTransition(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static CustomTransitionPage _slideTransition(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// Shell with bottom navigation
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首頁',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
