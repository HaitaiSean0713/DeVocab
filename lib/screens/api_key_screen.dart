import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _submit() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入 API Key')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<SettingsProvider>().saveApiKey(key);
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showApiGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('如何獲取 Gemini API Key？'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. 前往 Google AI Studio 網站 (aistudio.google.com)。'),
              SizedBox(height: 8),
              Text('2. 使用您的 Google 帳號登入。'),
              SizedBox(height: 8),
              Text('3. 點擊畫面左側的「Get API key」按鈕。'),
              SizedBox(height: 8),
              Text('4. 點擊「Create API key」，然後選擇或創建一個新專案。'),
              SizedBox(height: 8),
              Text('5. 複製生成的 API Key，並貼上到此頁面中。'),
              SizedBox(height: 16),
              Text(
                '請注意：目前 Gemini API 有提供免費額度，日常學習使用非常足夠！',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我明白了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: 0,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () async {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            // 若無路徑可退，表示是從登入頁導向過來，直接登出返回
                            await context.read<SettingsProvider>().clearApiKey();
                            await AuthService.instance.signOut();
                            if (context.mounted) context.go('/login');
                          }
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'WELCOME',
                            style: TextStyle(
                              fontFamily: 'NotoSansTC',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 3,
                              color: Color(0xFF8A8E8A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimary.withOpacity(0.12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: kPrimary,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          '歡迎來到 DeVocab',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: const Color(0xFF1A1C1A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '連結您的語言導師，開始自然地練習英文。',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: const Color(0xFF5A5E5A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 56),
                        // API Key input
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 12),
                            child: Text(
                              'API 金鑰 (API Key)',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: const Color(0xFF5A5E5A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: kPrimary.withOpacity(0.25)),
                          ),
                          child: TextField(
                            controller: _controller,
                            obscureText: _obscure,
                            style: AppTextStyles.bodyLarge,
                            decoration: InputDecoration(
                              hintText: '請輸入您的 API 金鑰',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA0A4A0),
                                fontFamily: 'NotoSansTC',
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 18),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.vpn_key_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF8A8E8A),
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _submit,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.bolt, size: 22),
                            label: const Text('開始'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'YOUR DATA IS ENCRYPTED AND SECURE',
                          style: AppTextStyles.label.copyWith(
                            color: const Color(0xFFA0A4A0),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () => _showApiGuideDialog(context),
                          icon: const Icon(Icons.help_outline, size: 20),
                          label: const Text('不知道如何獲取 API Key？教學點此'),
                          style: TextButton.styleFrom(
                            foregroundColor: kPrimary,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
