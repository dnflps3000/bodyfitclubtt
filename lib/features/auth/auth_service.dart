import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Trieda, ktorá rieši autentifikáciu.
// UI iba zavolá metódy z tejto triedy, aby nebola login logika rozhádzaná v obrazovkách.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.userChanges();

  // Uloží základný profil používateľa do Firestore.
  // Rovnaká metóda sa používa pre email, Google aj Facebook login.
  Future<void> _saveUserProfile(
    User user, {
    String? firstName,
    String? lastName,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    final providerIds = user.providerData.map((p) => p.providerId).toList();

    final data = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'providers': providerIds,
      'emailVerified': user.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // firstName a lastName zapisujeme iba vtedy, keď ich reálne posielame.
    // Tým sa pri Google/Facebook/email login-e neprepíšu na null.
    if (firstName != null) {
      data['firstName'] = firstName;
    }

    if (lastName != null) {
      data['lastName'] = lastName;
    }

    // createdAt nastavíme iba pri prvom vytvorení dokumentu.
    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await userDoc.set(data, SetOptions(merge: true));
  }

  // EMAIL + HESLO - REGISTRÁCIA
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    await _saveUserProfile(user);

    // Po registrácii pošleme overovací e-mail.
    await user.sendEmailVerification();

    // Používateľa hneď odhlásime, aby sa do aplikácie dostal až po potvrdení e-mailu.
    await _auth.signOut();

    return credential;
  }

  // EMAIL + HESLO - PRIHLÁSENIE
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    // Obnovíme údaje používateľa, aby Firebase zistil, či už klikol na overovací link.
    await user.reload();

    final refreshedUser = _auth.currentUser!;

    if (!refreshedUser.emailVerified) {
      await refreshedUser.sendEmailVerification();
      await _auth.signOut();

      throw FirebaseAuthException(code: 'email-not-verified');
    }

    await _saveUserProfile(refreshedUser);
    return credential;
  }

  // GOOGLE LOGIN
  Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    await _saveUserProfile(userCredential.user!);
    return userCredential;
  }

  // FACEBOOK LOGIN
  Future<UserCredential?> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      // public_profile = meno + profilová fotka
      // email = e-mailová adresa, ak ju Facebook používateľ poskytne
      permissions: ['public_profile', 'email'],
    );

    if (result.status == LoginStatus.cancelled) {
      throw FirebaseAuthException(code: 'sign-in-cancelled');
    }

    if (result.status != LoginStatus.success) {
      throw FirebaseAuthException(
        code: 'facebook-login-failed',
        message: result.message,
      );
    }

    final credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);

    final userCredential = await _auth.signInWithCredential(credential);

    await _saveUserProfile(userCredential.user!);
    return userCredential;
  }

  // ODHLÁSENIE
  Future<void> signOut() async {
    // Odhlásime iba Firebase session.
    // Google účet nechávame v zariadení zapamätaný kvôli pohodlnejšiemu ďalšiemu loginu.
    await _auth.signOut();
  }
}