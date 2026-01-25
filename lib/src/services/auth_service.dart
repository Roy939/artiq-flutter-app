import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _getGoogleSignIn {
    _googleSignIn ??= GoogleSignIn(
      // Web-specific configuration
      clientId: kIsWeb 
        ? '280578944842-v8nvsj23kv8n8ar3arju57fvng181f0f.apps.googleusercontent.com' 
        : null,
    );
    return _googleSignIn!;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle error
      print('Email/Password sign-in error: \${e.message}');
      return null;
    } catch (e) {
      print('Unexpected sign-in error: \$e');
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _getGoogleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle error
      print('Google sign-in error: \${e.message}');
      return null;
    } catch (e) {
      print('Unexpected Google sign-in error: \$e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      print('Sign-out error: \$e');
    }
  }
}
