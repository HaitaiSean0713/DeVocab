import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text.trim(),
        data: {'username': _usernameController.text.trim()},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('驗證信已寄出至 ${_emailController.text}'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
      );
        setState(() => _isLoading = false);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錯誤: ${e.message}')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('發生錯誤: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
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
                            color: kPrimary.withValues(alpha: 0.15),
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
                        const SizedBox(height: 36),
                        // Title
                        Text(
                          '建立帳號',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: colorScheme.onSurface,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '開始你的字彙探索之旅',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Username field
                        _buildTextField(
                          controller: _usernameController,
                          icon: Icons.person_outline,
                          hint: '使用者名稱',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return '請輸入使用者名稱';
                            }
                            if (v.trim().length < 2) {
                              return '名稱至少需要 2 個字元';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          hint: '電子信箱',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null ||
                                v.isEmpty ||
                                !v.contains('@')) {
                              return '請輸入有效的電子信箱';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  kPrimary.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '註冊',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Divider with "或"
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: kPrimary.withValues(alpha: 0.15),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '或',
                                style: AppTextStyles.caption.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: kPrimary.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Google button
                        _buildGlassButton(
                          onPressed: () async {
                            try {
                              await AuthService.instance.signInWithGoogle();
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
                                '使用 Google 繼續',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: const Color(0xFF3D3D3D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '已有帳號？',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                '登入',
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
                            color: kPrimary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: kPrimary),
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'NotoSansTC',
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          errorStyle: const TextStyle(height: 0.8),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kPrimary.withValues(alpha: 0.25)),
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

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), -0.3, 1.9, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 1.6, 1.1, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 2.7, 0.9, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 3.6, 0.9, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(center.dx, center.dy - radius * 0.12, center.dx + radius,
          center.dy + radius * 0.12),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
