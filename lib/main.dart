import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'providers/word_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';

// Variables map to .env values
late final String _supabaseUrl;
late final String _supabaseAnonKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // 移除 Web 上的 '#'，避免與 Supabase OAuth 回傳的 URL 衝突

  await dotenv.load(fileName: ".env");
  _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  runApp(const DeVocabApp());
}

class DeVocabApp extends StatefulWidget {
  const DeVocabApp({super.key});

  @override
  State<DeVocabApp> createState() => _DeVocabAppState();
}

class _DeVocabAppState extends State<DeVocabApp> {
  @override
  void initState() {
    super.initState();
    // 監聽 Auth 狀態改變
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.signedOut) {
        // 通知 Router 重新評估 _guard
        AppRouter.router.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WordProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            title: 'DeVocab',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
