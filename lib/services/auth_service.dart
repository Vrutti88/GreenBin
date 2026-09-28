import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Service managing all Firebase Authentication actions with safe fallback for testing.
class AuthService {
  final FirebaseAuth? _customAuth;

  AuthService({FirebaseAuth? auth}) : _customAuth = auth;

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (_isFirebaseReady) return FirebaseAuth.instance;
    return null;
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth == null) return const Stream.empty();
    return auth.authStateChanges();
  }

  /// Current authenticated user
  User? get currentUser => _auth?.currentUser;

  /// Check if user is logged in
  bool get isAuthenticated => _auth?.currentUser != null;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase is not initialized yet.');
    }
    try {
      return await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Register new user with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase is not initialized yet.');
    }
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Send password reset link to user's email
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception('Firebase is not initialized yet.');
    }
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update account password
  Future<void> updatePassword(String newPassword) async {
    final user = currentUser;
    if (user == null) throw Exception('No active user session found.');
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth?.signOut();
  }

  /// Format Firebase Auth errors into friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account exists with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'requires-recent-login':
        return 'Please log in again before changing your password.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
