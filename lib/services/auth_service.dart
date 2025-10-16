import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'desktop_google_oauth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  // Desktop app Client ID + optional secret (from your downloaded JSON)
  static const String googleDesktopClientId =
      '1033211347157-nkdtj0o41nk88duu3uai6d33rofp8q67.apps.googleusercontent.com';
  static const String googleDesktopClientSecret = ''; // paste if token endpoint complains

  static Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return await _auth.signInWithPopup(provider);
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw 'Sign-in aborted';
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    }

    final oauth = DesktopGoogleOAuth(
      clientId: googleDesktopClientId,
      clientSecret: googleDesktopClientSecret,
    );
    final tokens = await oauth.signIn();
    final credential = GoogleAuthProvider.credential(
      idToken: tokens['idToken'],
      accessToken: tokens['accessToken'],
    );
    return await _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    try { await GoogleSignIn().signOut(); } catch (_) {}
    await _auth.signOut();
  }
}
