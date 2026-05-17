import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/auth/presentation/complete_email_screen.dart';
import 'firebase_options.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_texts.dart';
import 'core/widgets/app_menu_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/complete_profile_screen.dart';
import 'features/home/presentation/public_home_screen.dart';
import 'features/main/main_navigation_screen.dart';
import 'features/schedule/presentation/public_schedule_screen.dart';
import 'features/settings/data/settings_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'features/messages/data/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SettingsService.instance.load();

  await NotificationService.initialize();

  Stripe.publishableKey =
      "pk_test_51TQtEE7i16mqcQZHN7bUfWOdwwmhreO884LAle2a2g3elrJcEONKIKtUvJdBcwAGg7oT9IP8tiRG58CfltSaQL6w00RUBrINmE";

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
          locale: settingsService.locale,
          supportedLocales: const [
            Locale('sk', 'SK'),
            Locale('en', 'GB'),
            Locale('de', 'DE'),
            Locale('fr', 'FR'),
            Locale('pl', 'PL'),
            Locale('hu', 'HU'),
            Locale('uk', 'UA'),
            Locale('ru', 'RU'),
            Locale('sr', 'RS'),
            Locale('cs', 'CZ'),
          ],
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
          'assets/splash_logo.png',
          width: 320,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class ActiveUserGate extends StatefulWidget {
  const ActiveUserGate({
    super.key,
    required this.user,
    required this.authService,
  });

  final User user;
  final AuthService authService;

  @override
  State<ActiveUserGate> createState() => _ActiveUserGateState();
}

class _ActiveUserGateState extends State<ActiveUserGate> {
  late Future<Map<String, dynamic>> _userGateFuture;

  Future<Map<String, dynamic>> _loadUserGateData() async {
    await widget.authService.ensureUserIsActive(widget.user);

    final userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();

    return userDocument.data() ?? {};
  }

  @override
  void initState() {
    super.initState();
    _userGateFuture = _loadUserGateData();
  }

  @override
  void didUpdateWidget(covariant ActiveUserGate oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.uid != widget.user.uid) {
      _userGateFuture = _loadUserGateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userGateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  AppTexts.inactiveAccount,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final userData = snapshot.data ?? {};

        final firestoreEmail = userData['email'] as String? ?? '';
        final authEmail = widget.user.email?.trim() ?? '';

        final needsEmail =
            firestoreEmail.trim().isEmpty && authEmail.trim().isEmpty;

        if (needsEmail) {
          return CompleteEmailScreen(
            onCompleted: () {
              setState(() {
                _userGateFuture = _loadUserGateData();
              });
            },
          );
        }

        final firestoreDisplayName = userData['displayName'] as String? ?? '';
        final needsProfile =
            firestoreDisplayName.trim().isEmpty &&
            (widget.user.displayName == null ||
                widget.user.displayName!.trim().isEmpty);

        if (needsProfile) {
          return const CompleteProfileScreen();
        }

        return MainNavigationScreen(user: widget.user);
      },
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
    final settingsService = SettingsService.instance;

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;

        if (isLoggedIn) {
          return ActiveUserGate(user: user, authService: authService);
        }

        return AnimatedBuilder(
          animation: settingsService,
          builder: (context, _) {
            const menuButton = AppMenuButton(
              showLogin: true,
              showLogout: false,
            );
            return Scaffold(
              appBar: AppBar(
                title: Text(AppTexts.appName),
                leading: settingsService.isRightHanded ? null : menuButton,
                actions: settingsService.isRightHanded ? [menuButton] : null,
              ),
              body: PublicHomeScreen(
                onOpenSchedule: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PublicScheduleScreen(),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
