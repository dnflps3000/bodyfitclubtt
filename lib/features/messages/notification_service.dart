import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();

    await saveToken();

    FirebaseAuth.instance.authStateChanges().listen((_) async {
      await saveToken();
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await saveToken(token);
    });
  }

  static Future<void> saveToken([String? refreshedToken]) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    final token =
        refreshedToken ??
        await FirebaseMessaging.instance.getToken();

    debugPrint('FCM TOKEN: $token');

    if (token == null) return;

    await FirebaseFirestore.instance
        .collection('fcmTokens')
        .doc(token)
        .set({
      'token': token,
      'userId': user?.uid,
      'isLoggedIn': user != null,
      'platform': 'android',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('FCM TOKEN SAVED');
  } catch (e) {
    debugPrint('FCM ERROR: $e');
  }
}
}