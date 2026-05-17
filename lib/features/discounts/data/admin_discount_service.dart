import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../audit/data/audit_log_service.dart';
import '../../../core/theme/app_texts.dart';

class AdminDiscountService {
  AdminDiscountService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AuditLogService _auditLogService = AuditLogService();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPendingDiscountRequests() {
    return _firestore
        .collection('discount_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> approveDiscountRequest({
    required String requestId,
    required String userId,
    required String discountType,
    required DateTime validUntil,
    String adminNote = '',
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('not-authenticated');
    }

    final requestRef = _firestore.collection('discount_requests').doc(requestId);
    final userRef = _firestore.collection('users').doc(userId);

    final batch = _firestore.batch();

    batch.update(requestRef, {
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': currentUser.uid,
      'approvedValidUntil': Timestamp.fromDate(validUntil),
      'adminNote': adminNote.trim(),
    });

    batch.set(userRef, {
      'discountType': discountType,
      'discountStatus': 'approved',
      'discountValidUntil': Timestamp.fromDate(validUntil),
      'discountVerifiedAt': FieldValue.serverTimestamp(),
      'discountVerifiedBy': currentUser.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();

    await _auditLogService.createLogWithUsers(
      category: 'discount',
      action: 'discount_approved',
      targetType: 'discount_request',
      targetId: requestId,
      targetUserId: userId,
      actor: currentUser,
      title: AppTexts.auditDiscountApprovedTitle,
      description: AppTexts.auditDiscountApprovedDescription,
      changes: {
        'discountType': {'oldValue': null, 'newValue': discountType},
        'discountStatus': {'oldValue': 'pending', 'newValue': 'approved'},
        'discountValidUntil': {
          'oldValue': null,
          'newValue': Timestamp.fromDate(validUntil),
        },
        if (adminNote.trim().isNotEmpty)
          'adminNote': {'oldValue': null, 'newValue': adminNote.trim()},
      },
    );
  }

  Future<void> rejectDiscountRequest({
    required String requestId,
    required String userId,
    String adminNote = '',
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('not-authenticated');
    }

    final requestRef = _firestore.collection('discount_requests').doc(requestId);
    final userRef = _firestore.collection('users').doc(userId);

    final batch = _firestore.batch();

    batch.update(requestRef, {
      'status': 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': currentUser.uid,
      'adminNote': adminNote.trim(),
    });

    batch.set(userRef, {
      'discountStatus': 'rejected',
      'discountValidUntil': null,
      'discountVerifiedAt': null,
      'discountVerifiedBy': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();

    await _auditLogService.createLogWithUsers(
      category: 'discount',
      action: 'discount_rejected',
      targetType: 'discount_request',
      targetId: requestId,
      targetUserId: userId,
      actor: currentUser,
      title: AppTexts.auditDiscountRejectedTitle,
      description: AppTexts.auditDiscountRejectedDescription,
      changes: {
        'discountStatus': {'oldValue': 'pending', 'newValue': 'rejected'},
        if (adminNote.trim().isNotEmpty)
          'adminNote': {'oldValue': null, 'newValue': adminNote.trim()},
      },
    );
  }
}