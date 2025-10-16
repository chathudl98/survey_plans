import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/office_screen.dart';
import 'screens/plan_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const _Gatekeeper(),
    );
  }
}

class _Gatekeeper extends StatefulWidget {
  const _Gatekeeper();

  @override
  State<_Gatekeeper> createState() => _GatekeeperState();
}

class _GatekeeperState extends State<_Gatekeeper> {
  String? officeId;

  @override
  void initState() {
    super.initState();
    _loadOffice();
  }

  Future<void> _loadOffice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => officeId = prefs.getString('officeId'));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == null) return const LoginScreen();
        if (officeId == null) return const OfficeScreen();
        return PlanListScreen(officeId: officeId!);
      },
    );
  }
}
