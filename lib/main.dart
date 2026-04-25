import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_texts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// Hlavná trieda aplikácie.
// Tu sa nastavuje globálny theme aplikácie a štartovacia obrazovka.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Skryje debug banner
      title: AppTexts.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppSplashScreen(),
    );
  }
}

/* Prvá obrazovka po natívnom splash screene. Android 12+ natívny splash
zobrazuje skôr ikonku, preto tu zobrazíme krajší obrázok s názvom aplikácie. */
class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();

    // Po krátkom čase používateľa presunieme na hlavnú obrazovku.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Farbu pozadia berieme z globálneho theme, nie natvrdo z kódu.
      backgroundColor: AppTheme.splashBackground(
        Theme.of(context).brightness,
      ),
      body: Center(
        child: Image.asset(
          'assets/splash.png',
          width: 320,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Zatiaľ jednoduchá hlavná obrazovka.
/// Neskôr sem pridáme login, profil a rezervácie.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.appName)),
      body: const Center(
        child: Text(AppTexts.firebaseWorks),
      ),
    );
  }
}