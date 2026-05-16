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

  bool isEmailPasswordUser(User user) {
    return user.providerData.any((provider) {
      return provider.providerId == 'password';
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.setLanguageCode('sk');
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }

    final currentEmail = user.email?.trim();

    if (currentEmail == null || currentEmail.isEmpty) {
      throw FirebaseAuthException(code: 'missing-current-email');
    }

    if (!isEmailPasswordUser(user)) {
      throw FirebaseAuthException(code: 'email-change-not-available');
    }

    final credential = EmailAuthProvider.credential(
      email: currentEmail,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    await _auth.setLanguageCode('sk');
    await user.verifyBeforeUpdateEmail(newEmail.trim());

    await _firestore.collection('users').doc(user.uid).set({
      'pendingEmail': newEmail.trim(),
      'emailChangeRequestedAt': FieldValue.serverTimestamp(),
      'emailChangeSource': 'self_service',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> ensureUserIsActive(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();

    final isActive = data?['isActive'] as bool? ?? true;

    if (!isActive) {
      await signOut();
      throw FirebaseAuthException(code: 'user-disabled-in-app');
    }

    final authEmail = user.email?.trim();
    final firestoreEmail = (data?['email'] as String?)?.trim();
    final pendingEmail = (data?['pendingEmail'] as String?)?.trim();

    if (authEmail != null &&
        authEmail.isNotEmpty &&
        authEmail != firestoreEmail) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': authEmail,
        'pendingEmail': FieldValue.delete(),
        'emailChangeCompletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (pendingEmail != null && pendingEmail.isNotEmpty)
          'previousEmail': firestoreEmail ?? '',
      }, SetOptions(merge: true));
    }
  }

  // Uloží základný profil používateľa do Firestore.
  // Rovnaká metóda sa používa pre email, Google aj Facebook login.
  Future<void> _saveUserProfile(
    User user, {
    String? firstName,
    String? lastName,
    String? photoURL,
    String? termsVersion,
    String? privacyVersion,
    String? consentSource,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    final existingData = snapshot.data();
    final providerIds = user.providerData.map((p) => p.providerId).toList();
    final providerPhotoURL = photoURL ?? user.photoURL;
    final photoUpdatedManually =
        existingData?['photoUpdatedManually'] as bool? ?? false;

    final displayName = user.displayName?.trim() ?? '';
    final existingPublicName = existingData?['publicName'] as String? ?? '';

    final generatedPublicName = firstName?.trim().isNotEmpty == true
        ? firstName!.trim()
        : displayName.isNotEmpty
        ? displayName.split(' ').first
        : null;

    final authEmail = user.email?.trim() ?? '';
    final existingEmail = existingData?['email'] as String? ?? '';

    final Map<String, dynamic> data = {
      'uid': user.uid,
      'displayName': user.displayName,
      'providerPhotoURL': providerPhotoURL,
      'providers': providerIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (authEmail.isNotEmpty) {
      data['email'] = authEmail;
      data['emailSource'] = 'auth';
      data['emailVerified'] = user.emailVerified;
    } else if (existingEmail.trim().isEmpty) {
      data['email'] = '';
      data['emailSource'] = 'missing';
      data['emailVerified'] = false;
    }

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
      data['isActive'] = true;
    } else if (existingData == null || !existingData.containsKey('role')) {
      data['role'] = AppRoles.user;
    }

    if (existingPublicName.trim().isEmpty &&
        generatedPublicName != null &&
        generatedPublicName.isNotEmpty) {
      data['publicName'] = generatedPublicName;
    }

    if (termsVersion != null &&
        privacyVersion != null &&
        consentSource != null) {
      if (existingData?['termsAcceptedAt'] == null) {
        data['termsAcceptedAt'] = FieldValue.serverTimestamp();
      }

      if (existingData?['privacyAcceptedAt'] == null) {
        data['privacyAcceptedAt'] = FieldValue.serverTimestamp();
      }

      data['termsVersion'] = termsVersion;
      data['privacyVersion'] = privacyVersion;
      data['consentSource'] = consentSource;
    }

    await userDoc.set(data, SetOptions(merge: true));
  }

  // EMAIL + HESLO - REGISTRÁCIA
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String termsVersion,
    required String privacyVersion,
    required String consentSource,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    await _saveUserProfile(
      user,
      termsVersion: termsVersion,
      privacyVersion: privacyVersion,
      consentSource: consentSource,
    );

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
    await ensureUserIsActive(refreshedUser);

    return credential;
  }

  // GOOGLE LOGIN
  Future<UserCredential?> signInWithGoogle({
    String? termsVersion,
    String? privacyVersion,
    String? consentSource,
  }) async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize();

    final googleUser = await googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final user = userCredential.user!;

    await _saveUserProfile(
      user,
      termsVersion: termsVersion,
      privacyVersion: privacyVersion,
      consentSource: consentSource,
    );
    await ensureUserIsActive(user);

    return userCredential;
  }

  // FACEBOOK LOGIN
  Future<UserCredential?> signInWithFacebook({
    String? termsVersion,
    String? privacyVersion,
    String? consentSource,
  }) async {
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

    final user = userCredential.user!;

    await _saveUserProfile(
      user,
      photoURL: facebookPhotoUrl,
      termsVersion: termsVersion,
      privacyVersion: privacyVersion,
      consentSource: consentSource,
    );
    await ensureUserIsActive(user);

    return userCredential;
  }

  // ODHLÁSENIE
  Future<void> signOut() async {
    await _auth.signOut();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google session nemusí byť aktívna.
    }

    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {
      // Facebook session nemusí byť aktívna.
    }
  }
}
