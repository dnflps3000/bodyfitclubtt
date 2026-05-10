import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_roles.dart';

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
    String? photoURL,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    final existingData = snapshot.data();
    final providerIds = user.providerData.map((p) => p.providerId).toList();
    final providerPhotoURL = photoURL ?? user.photoURL;
    final photoUpdatedManually =
        existingData?['photoUpdatedManually'] as bool? ?? false;

    final displayName = user.displayName?.trim() ?? '';
    final existingPublicName =
        existingData?['publicName'] as String? ?? '';

    final generatedPublicName = firstName?.trim().isNotEmpty == true
        ? firstName!.trim()
        : displayName.isNotEmpty
            ? displayName.split(' ').first
            : null;

    final Map<String, dynamic> data = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'providerPhotoURL': providerPhotoURL,
      'providers': providerIds,
      'emailVerified': user.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!photoUpdatedManually) {
      data['photoURL'] = providerPhotoURL;
    }

    if (firstName != null) {
      data['firstName'] = firstName;
    }

    if (lastName != null) {
      data['lastName'] = lastName;
    }

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['role'] = AppRoles.user;
      data['photoUpdatedManually'] = false;
    } else if (existingData == null || !existingData.containsKey('role')) {
      data['role'] = AppRoles.user;
    }

    if (existingPublicName.trim().isEmpty &&
        generatedPublicName != null &&
        generatedPublicName.isNotEmpty) {
      data['publicName'] = generatedPublicName;
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

    final userData = await FacebookAuth.instance.getUserData(
      fields: 'name,email,picture.width(800).height(800)',
    );

    final facebookPhotoUrl = userData['picture']?['data']?['url'] as String?;

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    await _saveUserProfile(userCredential.user!, photoURL: facebookPhotoUrl);

    return userCredential;
  }

  // ODHLÁSENIE
  Future<void> signOut() async {
    // Odhlásime iba Firebase session.
    // Google účet nechávame v zariadení zapamätaný kvôli pohodlnejšiemu ďalšiemu loginu.
    await _auth.signOut();
  }
}
