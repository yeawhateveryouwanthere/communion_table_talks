import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Wraps Firebase Auth for sign-in, sign-up, and sign-out.
///
/// Supports Google Sign-In and email/password authentication.
/// Automatically creates a Firestore user document on first sign-in.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '6523279108-m8n848flm5nu4bs7ml560rudu4nejp53.apps.googleusercontent.com',
  );
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// The currently signed-in user, or null.
  static User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google.
  /// Returns the User on success, null on cancel/failure.
  static Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _ensureUserDocument(userCredential.user!);
      return userCredential.user;
    } catch (e) {
      print('Google sign-in error: $e');
      throw 'Google Sign-In failed. Please try again.';
    }
  }

  /// Sign in with email and password.
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDocument(userCredential.user!);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Create a new account with email and password.
  static Future<User?> createAccountWithEmail(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDocument(userCredential.user!);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Send a password reset email.
  static Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Sign out from all providers.
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Ensures a Firestore user document exists for the given user.
  /// Creates one with free tier if it doesn't exist yet.
  static Future<void> _ensureUserDocument(User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'email': user.email,
        'displayName': user.displayName,
        'subscriptionTier': 'free',
        'createdAt': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Maps Firebase auth exceptions to user-friendly error messages.
  static String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
