import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_texts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/complete_profile_screen.dart';
import 'features/home/presentation/public_home_screen.dart';
import 'features/main/main_navigation_screen.dart';
import 'features/schedule/presentation/public_schedule_screen.dart';
import 'features/settings/data/settings_service.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'features/messages/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService.initialize();

  Stripe.publishableKey =
      "pk_test_51TQtEE7i16mqcQZHN7bUfWOdwwmhreO884LAle2a2g3elrJcEONKIKtUvJdBcwAGg7oT9IP8tiRG58CfltSaQL6w00RUBrINmE";

  await SettingsService.instance.load();

  runApp(MyApp(settingsService: SettingsService.instance));
}

// Hlavná trieda aplikácie.
// Tu sa nastavuje globálny theme aplikácie a štartovacia obrazovka.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsService});

  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsService,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppTexts.appName,
          locale: const Locale('sk', 'SK'),
          supportedLocales: const [Locale('sk', 'SK')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsService.themeMode,
          home: const AppSplashScreen(),
        );
      },
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

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Farbu pozadia berieme z globálneho theme, nie natvrdo z kódu.
      backgroundColor: AppTheme.splashBackground(Theme.of(context).brightness),
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

// Zatiaľ jednoduchá hlavná obrazovka.
// Je verejná, takže rozvrh bude viditeľný aj bez prihlásenia.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;

        final needsProfile =
            isLoggedIn &&
            (user.displayName == null || user.displayName!.trim().isEmpty);

        if (needsProfile) {
          return const CompleteProfileScreen();
        }

        if (isLoggedIn) {
          return MainNavigationScreen(user: user);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppTexts.appName),
            actions: [
              IconButton(
                tooltip: AppTexts.settings,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              IconButton(
                tooltip: AppTexts.login,
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
          body: PublicHomeScreen(
            onOpenSchedule: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PublicScheduleScreen()),
              );
            },
          ),
        );
      },
    );
  }
}
