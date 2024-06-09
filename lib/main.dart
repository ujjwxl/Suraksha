import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackingapp/auth/auth.dart';
import 'package:trackingapp/firebase_options.dart';
import 'package:trackingapp/pages/home_page.dart';
import 'package:trackingapp/pages/login_page.dart';
import 'package:trackingapp/pages/onboarding_page.dart';
import 'package:trackingapp/pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool showHome = prefs.getBool('showHome') ?? false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(showHome: showHome));
}

class MyApp extends StatelessWidget {
  final bool showHome;

  const MyApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showHome ? const AuthPage() : const OnboardingPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
