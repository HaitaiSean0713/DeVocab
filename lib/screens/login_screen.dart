import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _sendVerificationEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('驗證信已寄出至 ${_emailController.text}，請前往信箱點擊連結。'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錯誤: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('發生錯誤: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    // Logo
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimary.withOpacity(0.15),
                      ),
                      child: const Icon(Icons.menu_book,
                          color: kPrimary, size: 44),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DEVOCAB',
                      style: AppTextStyles.label.copyWith(
                        color: kPrimary,
                        letterSpacing: 4,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Hero image - zen garden oval
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            kPrimary.withOpacity(0.3),
                            kPrimary.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 80,
                          color: kPrimary.withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Title
                    Text(
                      '登入與註冊',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: colorScheme.onSurface,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Form
                    Form(
                      key: _formKey,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? kSurfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: kPrimary.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTextStyles.bodyLarge,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.email_outlined, color: kPrimary),
                            hintText: '輸入電子信箱...',
                            hintStyle: TextStyle(
                              fontFamily: 'NotoSansTC',
                              color: isDark ? const Color(0xFF6A6E6A) : Colors.grey.shade400,
                              fontSize: 15,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || !value.contains('@')) {
                              return '請輸入有效的電子信箱';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Magic Link button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _sendVerificationEmail,
                        icon: const Icon(Icons.mark_email_read_outlined, size: 20),
                        label: const Text('寄送登入/註冊驗證信'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Google button - frosted glass style
                    _buildGlassButton(
                      context,
                      isDark: isDark,
                      onPressed: () async {
                        try {
                          await AuthService.instance.signInWithGoogle();
                          // Web 版會整頁重新導向 Google，後續處理交給 main.dart 的 onAuthStateChange
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Google 登入失敗: $e')),
                            );
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GoogleLogo(),
                          const SizedBox(width: 12),
                          Text(
                            '使用 Google 帳號登入',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: isDark ? const Color(0xFFE2E6E2) : const Color(0xFF3D3D3D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '還沒有帳號？',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            '註冊',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: kPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    // Bottom bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(
      BuildContext context,
      {required VoidCallback onPressed,
      required Widget child,
      required bool isDark}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: isDark ? kSurfaceDark : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kPrimary.withOpacity(0.25)),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Simplified Google G colors
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -0.3, 1.9, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        1.6, 1.1, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        2.7, 0.9, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        3.6, 0.9, true, paint);

    // White center
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);
    // Blue bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(
          center.dx, center.dy - radius * 0.12,
          center.dx + radius, center.dy + radius * 0.12),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
