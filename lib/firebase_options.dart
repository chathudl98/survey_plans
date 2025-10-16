import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    } else {
      return windows;
    }
  }

  // Android configuration (from google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAT00DgjeyBqJ0hIfH36kd6bwKEfh12C0o',
    appId: '1:1064589097331:android:f06d1a57d9e54a877a2d06',
    messagingSenderId: '1064589097331',
    projectId: 'gsl-plan-database',
    storageBucket: 'gsl-plan-database.firebasestorage.app',
  );

  // Temporary Windows config — fill these from your Web app later
  static const FirebaseOptions windows = FirebaseOptions(
      apiKey: "AIzaSyAULFu4v7kyNCy3On1wlnVuNICsfVMjcCA",
  authDomain: "gsl-plan-database.firebaseapp.com",
  projectId: "gsl-plan-database",
  storageBucket: "gsl-plan-database.firebasestorage.app",
  messagingSenderId: "1064589097331",
  appId: "1:1064589097331:web:dba9d8aa9bddbd567a2d06",
  measurementId: "G-NP5XVZBTE8"
  );
}
