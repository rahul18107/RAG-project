import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  static User? get currentUser => _supabase.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get onAuthStateChange =>
      _supabase.auth.onAuthStateChange;

  // sign in with email + password
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // make sure the profile row exists (e.g. first login
    // after signing up with email confirmation ON)
    if (response.user != null) {
      await _ensureProfile(response.user!);
    }
  }

  // sign up + create profile row
  static Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    // profile row can only be created when we have a session
    // (with email confirmation ON there is no session yet —
    // the row is created on first login instead)
    if (response.session != null && response.user != null) {
      await _ensureProfile(response.user!, name: name);
    }
  }

  // create the profile row if it doesn't exist yet
  static Future<void> _ensureProfile(User user, {String? name}) async {
    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'name': name ??
            user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            'User',
      });
    } catch (_) {
      // profile row is not critical for using the app
    }
  }

  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // fetch the logged-in user's profile
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;

    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }
}
