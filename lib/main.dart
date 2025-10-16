import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/access_denied_screen.dart';
import 'services/user_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SurveyPlansApp());
}

class SurveyPlansApp extends StatelessWidget {
  const SurveyPlansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Survey Plans',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const _RootGate(),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snap.hasData) return const LoginScreen();
        return FutureBuilder<bool>(
          future: UserGuard.isAllowed(),
          builder: (context, allowSnap) {
            if (!allowSnap.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (allowSnap.data == true) {
              return const HomeScreen();
            } else {
              return const AccessDeniedScreen();
            }
          },
        );
      },
    );
  }
}
