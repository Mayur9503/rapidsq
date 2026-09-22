import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  FirebaseAuth? get _auth {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? const Stream.empty();

  User? get currentUser => _auth?.currentUser;

  bool get isAuthenticated => currentUser != null;

  String? get currentUserId => currentUser?.uid;

  /// Register user with Email, Password, Full Name, and Phone
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(fullName.trim());

        final firestore = _firestore;
        if (firestore != null) {
          // Create base user document in Firestore users/{uid}
          await firestore.collection('users').doc(user.uid).set({
            'name': fullName.trim(),
            'email': email.trim(),
            'phone': phone.trim(),
            'role': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Initialize empty or default medical profile for user
          await firestore.collection('medical_profiles').doc(user.uid).set({
            'name': fullName.trim(),
            'age': 21,
            'gender': 'Not specified',
            'bloodGroup': 'O+',
            'allergies': 'None',
            'conditions': 'None',
            'medications': 'None',
            'emergencyContact': phone.trim(),
            'contacts': [
              {
                'name': 'Primary Contact',
                'relationship': 'Family',
                'phone': phone.trim(),
                'isPrimary': true,
              }
            ],
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getFriendlyAuthError(e);
    } catch (e) {
      throw 'An unexpected registration error occurred: $e';
    }
  }

  /// Sign in with Email and Password
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _getFriendlyAuthError(e);
    } catch (e) {
      throw 'An unexpected login error occurred: $e';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
    }
  }

  String _getFriendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account registered with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please verify your credentials.';
      case 'invalid-credential':
        return 'Invalid email or password combination.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment before trying again.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
