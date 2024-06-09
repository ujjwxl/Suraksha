import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackingapp/auth/auth.dart';
import 'package:trackingapp/firebase_options.dart';
import 'package:trackingapp/pages/home_page.dart';
import 'package:trackingapp/pages/login_page.dart';
import 'package:trackingapp/pages/onboarding_page.dart';
import 'package:trackingapp/pages/signup_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trackingapp/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool showHome = prefs.getBool('showHome') ?? false;
  LanguageProvider languageProvider = LanguageProvider();
  await languageProvider.loadSelectedLanguage();
  runApp(
    ChangeNotifierProvider.value(
      value: languageProvider,
      // create: (context) => LanguageProvider(),
      child: MyApp(showHome: showHome),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showHome;

  const MyApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],

      // locale: const Locale('en'),

      locale: context.watch<LanguageProvider>().selectedLocale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      debugShowCheckedModeBanner: false,
      // home: showHome ? const AuthPage() : const OnboardingPage(),
      home: const OnboardingPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
