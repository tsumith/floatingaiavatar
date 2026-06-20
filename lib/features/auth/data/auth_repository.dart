import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository({required SupabaseClient supabase}) : _supabase = supabase;

  /// Auth state stream
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  /// Current user session 
  Session? get currentSession =>
      _supabase.auth.currentSession;

  /// Email + password sign-in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Email + password sign-up
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Google OAuth sign-in
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn.instance.authenticate();

    if (googleUser == null) {
      throw Exception('Google sign-in cancelled');
    }

    final GoogleSignInAuthentication auth =
        await googleUser.authentication;

    final String? idToken = auth.idToken;
    if (idToken == null) {
      throw Exception('Missing Google ID token');
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }
}