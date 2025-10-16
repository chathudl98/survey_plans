import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static Future<UserCredential> signInWithGoogle() async {
    // Android: use interactive flow
    if (Platform.isAndroid) {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw 'Sign-in aborted';
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    }

    // Other platforms (web/desktop) via popup
    final provider = GoogleAuthProvider();
    return await _auth.signInWithProvider(provider);
  }

  static Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
