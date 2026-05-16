import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../data/auth_service.dart';

// Režim obrazovky – používateľ sa buď prihlasuje,
// alebo vytvára nový účet cez e-mail a heslo.
enum AuthMode { login, register }

// Obrazovka pre prihlásenie a registráciu.
// Google/Facebook tlačidlá sú univerzálne:
// ak účet ešte neexistuje, Firebase ho vytvorí,
// ak už existuje, používateľa prihlási.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const String _lastUsedEmailKey = 'last_used_email';

  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadLastUsedEmail();
  }

  Future<void> _loadLastUsedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEmail = prefs.getString(_lastUsedEmailKey);

    if (!mounted || lastEmail == null) return;

    _emailController.text = lastEmail;
  }

  Future<void> _saveLastUsedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUsedEmailKey, email);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _validateRegistrationConsents() {
    if (_mode != AuthMode.register) {
      return;
    }

    if (!_termsAccepted) {
      throw AppTexts.termsConsentRequired;
    }

    if (!_privacyAccepted) {
      throw AppTexts.privacyConsentRequired;
    }
  }

  String _authErrorMessage(Object error) {
    if (error is String) {
      return error;
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return AppTexts.invalidEmailFormat;
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return AppTexts.wrongEmailOrPassword;
        case 'email-already-in-use':
          return AppTexts.userAlreadyExists;
        case 'weak-password':
          return AppTexts.weakPassword;
        case 'too-many-requests':
          return AppTexts.tooManyRequests;
        case 'network-request-failed':
          return AppTexts.networkError;
        case 'user-disabled-in-app':
        case 'user-disabled':
          return AppTexts.inactiveAccount;
        case 'email-not-verified':
          return '${AppTexts.emailNotVerified} ${AppTexts.verificationEmailSentAgain}';
        case 'sign-in-cancelled':
          return AppTexts.signInCancelled;
        case 'facebook-login-failed':
          return AppTexts.facebookLoginFailed;
        default:
          return AppTexts.unknownAuthError;
      }
    }
    return AppTexts.unknownAuthError;
  }

  Future<void> _showInfoDialog(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTexts.registerTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppTexts.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _runAuthAction(
    Future<void> Function() action, {
    String? successMessage,
  }) async {
    setState(() => _isLoading = true);

    try {
      await action();

      if (!mounted) return;

      if (successMessage != null) {
        await _showInfoDialog(successMessage);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_authErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
  }

  Future<void> _submitEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      throw AppTexts.fillEmailPassword;
    }

    if (!email.contains('@') || !email.contains('.')) {
      throw AppTexts.invalidEmailFormat;
    }

    if (_mode == AuthMode.register && password.length < 6) {
      throw AppTexts.passwordTooShort;
    }

    if (_mode == AuthMode.login) {
      await _authService.loginWithEmail(email: email, password: password);
    } else {
      _validateRegistrationConsents();

      await _authService.registerWithEmail(
        email: email,
        password: password,
        termsVersion: AppTexts.termsVersion,
        privacyVersion: AppTexts.privacyVersion,
        consentSource: 'email_password',
      );
    }

    await _saveLastUsedEmail(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoginMode = _mode == AuthMode.login;

    return Scaffold(
      appBar: AppBar(
        title: Text(isLoginMode ? AppTexts.loginTitle : AppTexts.registerTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Google/Facebook slúžia ako „pokračovať“:
                // používateľ nemusí riešiť rozdiel medzi loginom a registráciou.
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _runAuthAction(() async {
                          _validateRegistrationConsents();

                          await _authService.signInWithGoogle(
                            termsVersion: isLoginMode
                                ? null
                                : AppTexts.termsVersion,
                            privacyVersion: isLoginMode
                                ? null
                                : AppTexts.privacyVersion,
                            consentSource: isLoginMode ? null : 'google',
                          );
                        }),
                  icon: Image.asset('assets/auth/google.png', height: 22),
                  label: const Text(AppTexts.continueWithGoogle),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                ElevatedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _runAuthAction(() async {
                          _validateRegistrationConsents();

                          await _authService.signInWithFacebook(
                            termsVersion: isLoginMode
                                ? null
                                : AppTexts.termsVersion,
                            privacyVersion: isLoginMode
                                ? null
                                : AppTexts.privacyVersion,
                            consentSource: isLoginMode ? null : 'facebook',
                          );
                        }),
                  icon: Image.asset('assets/auth/facebook.png', height: 22),
                  label: const Text(AppTexts.continueWithFacebook),
                ),

                const SizedBox(height: AppSpacing.xl),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.cardGap,
                      ),
                      child: Text(AppTexts.or),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // E-mail a heslo používame len pri klasickom účte.
                TextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppTexts.email,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _runAuthAction(
                        _submitEmailAuth,
                        successMessage: isLoginMode
                            ? null
                            : AppTexts.verificationEmailSent,
                      );
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: AppTexts.password,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                if (!isLoginMode) ...[
                  CheckboxListTile(
                    value: _termsAccepted,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppTexts.acceptTerms),
                    subtitle: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => _openUrl(AppTexts.bodyFitClubWebsite),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppTexts.openTerms),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: _privacyAccepted,
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _privacyAccepted = value ?? false;
                            });
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppTexts.acceptPrivacy),
                    subtitle: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => _openUrl(AppTexts.bodyFitClubWebsite),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppTexts.openPrivacy),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                ],
                const SizedBox(height: AppSpacing.sectionGap),

                FilledButton(
                  onPressed: _isLoading
                      ? null
                      : () => _runAuthAction(
                          _submitEmailAuth,
                          successMessage: isLoginMode
                              ? null
                              : AppTexts.verificationEmailSent,
                        ),
                  child: Text(isLoginMode ? AppTexts.login : AppTexts.register),
                ),
                const SizedBox(height: AppSpacing.sm),

                TextButton(
                  onPressed: _isLoading ? null : _toggleMode,
                  child: Text(
                    isLoginMode
                        ? AppTexts.noAccountRegister
                        : AppTexts.hasAccountLogin,
                  ),
                ),

                if (_isLoading) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
