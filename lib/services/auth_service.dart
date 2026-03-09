import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _supabase = Supabase.instance.client;

  static const _webClientId =
      '507592226975-hve20kvcu7o2ij05bj14t7bfhmn6n96d.apps.googleusercontent.com';

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      // 在 Web 平台上，使用 Supabase 內建的 OAuth 重新導向是最穩定的作法
      // 不需要拿 idToken，也不會受限於 Google Identity Services 的按鈕限制
      final redirectUrl = kReleaseMode 
          ? 'https://haitaisean0713.github.io/DeVocab/' 
          : Uri.base.origin;
          
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    } else {
      // 以下是 iOS/Android 平台適用的 ID Token 邏輯
      final googleSignIn = GoogleSignIn(
        clientId: _webClientId, // 這裡之後如果是 App 要換成 Android/iOS 的 Client ID
        scopes: ['email'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('使用者取消了 Google 登入');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw AuthException('無法取得 Google ID Token');
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    }
  }

  /// Email Magic Link
  Future<void> signInWithEmail(String email, {Map<String, dynamic>? data}) {
    return _supabase.auth.signInWithOtp(
      email: email.trim(),
      data: data,
    );
  }

  /// 登出
  Future<void> signOut() => _supabase.auth.signOut();

  /// 目前 session
  Session? get currentSession => _supabase.auth.currentSession;

  /// 監聽 auth 狀態
  Stream<AuthState> get onAuthStateChange =>
      _supabase.auth.onAuthStateChange;
}
