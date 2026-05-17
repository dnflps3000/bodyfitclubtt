import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../audit/data/audit_log_service.dart';
import '../../../core/theme/app_texts.dart';

class DiscountService {
  DiscountService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final AuditLogService _auditLogService = AuditLogService();

  Future<void> requestDiscount({
    required String requestedType,
    required File documentFile,
    String note = '',
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('not-authenticated');
    }

    final userRef = _firestore.collection('users').doc(currentUser.uid);
    final userSnapshot = await userRef.get();
    final userData = userSnapshot.data() ?? {};

    final currentStatus = userData['discountStatus'] as String? ?? 'none';

    if (currentStatus == 'pending') {
      throw Exception('discount-request-already-pending');
    }

    final requestRef = _firestore.collection('discount_requests').doc();

    final documentPath =
        'discount_documents/${currentUser.uid}/${requestRef.id}.jpg';

    final uploadTask = await _storage.ref(documentPath).putFile(documentFile);

    final documentImageUrl = await uploadTask.ref.getDownloadURL();

    final batch = _firestore.batch();

    batch.set(requestRef, {
      'userId': currentUser.uid,
      'userRef': userRef,
      'userName':
          userData['displayName'] as String? ?? currentUser.displayName ?? '',
      'userEmail': userData['email'] as String? ?? currentUser.email ?? '',
      'requestedType': requestedType,
      'status': 'pending',
      'note': note.trim(),
      'documentImageUrl': documentImageUrl,
      'documentPath': documentPath,
      'createdAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
      'reviewedBy': null,
      'approvedValidUntil': null,
      'adminNote': null,
    });

    batch.set(userRef, {
      'discountType': requestedType,
      'discountStatus': 'pending',
      'discountRequestedAt': FieldValue.serverTimestamp(),
      'discountRequestId': requestRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();

    await _auditLogService.createLogWithUsers(
      category: 'discount',
      action: 'discount_requested',
      targetType: 'discount_request',
      targetId: requestRef.id,
      targetUserId: currentUser.uid,
      actor: currentUser,
      title: AppTexts.auditDiscountRequestedTitle,
      description: AppTexts.auditDiscountRequestedDescription,
      changes: {
        'requestedType': {'oldValue': null, 'newValue': requestedType},
        'status': {'oldValue': null, 'newValue': 'pending'},
      },
    );
  }
}
