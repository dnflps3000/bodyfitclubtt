import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/audit_log.dart';

class AuditLogService {
  AuditLogService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, String>> loadUserAuditInfo(String userId) async {
    if (userId.isEmpty) {
      return {'name': '', 'email': '', 'role': ''};
    }

    final userSnapshot = await _firestore.collection('users').doc(userId).get();
    final userData = userSnapshot.data() ?? {};

    return {
      'name': _resolveUserDisplayName(userId, userData),
      'email': userData['email'] as String? ?? '',
      'role': userData['role'] as String? ?? '',
    };
  }

  String _resolveUserDisplayName(String userId, Map<String, dynamic> data) {
    final publicName = data['publicName'] as String? ?? '';
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';
    final displayName = data['displayName'] as String? ?? '';
    final email = data['email'] as String? ?? '';

    if (publicName.trim().isNotEmpty) {
      return publicName.trim();
    }

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    if (email.trim().isNotEmpty) {
      return email.trim();
    }

    return userId;
  }

  Future<void> createLogWithUsers({
    required String category,
    required String action,
    required String targetType,
    required String targetId,
    required String targetUserId,
    required String title,
    required String description,
    Map<String, dynamic> changes = const {},
    User? actor,
  }) async {
    final currentActor = actor ?? FirebaseAuth.instance.currentUser;

    final actorInfo = currentActor == null
        ? {'name': '', 'email': '', 'role': ''}
        : await loadUserAuditInfo(currentActor.uid);

    final targetUserInfo = await loadUserAuditInfo(targetUserId);

    await createLog(
      category: category,
      action: action,
      targetType: targetType,
      targetId: targetId,
      title: title,
      description: description,
      targetUserId: targetUserId,
      targetUserName: targetUserInfo['name'],
      targetUserEmail: targetUserInfo['email'],
      actor: currentActor,
      actorName: actorInfo['name'],
      actorEmail: actorInfo['email'],
      actorRole: actorInfo['role'],
      changes: changes,
    );
  }

  Future<void> createLog({
    required String category,
    required String action,
    required String targetType,
    required String targetId,
    required String title,
    required String description,
    String? targetUserId,
    String? targetUserName,
    String? targetUserEmail,
    Map<String, dynamic> changes = const {},
    User? actor,
    String? actorRole,
    String? actorName,
    String? actorEmail,
  }) async {
    final currentActor = actor ?? FirebaseAuth.instance.currentUser;

    await _firestore.collection('auditLogs').add({
      'category': category,
      'action': action,
      'actorId': currentActor?.uid ?? '',
      'actorName': actorName ?? currentActor?.displayName ?? '',
      'actorEmail': actorEmail ?? currentActor?.email ?? '',
      'actorRole': actorRole ?? '',
      'targetType': targetType,
      'targetId': targetId,
      'targetUserId': targetUserId ?? '',
      'targetUserName': targetUserName ?? '',
      'targetUserEmail': targetUserEmail ?? '',
      'title': title,
      'description': description,
      'changes': changes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<AuditLog>> loadAuditLogs({
    String searchQuery = '',
    String category = '',
    String action = '',
    String actorRole = '',
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 500,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('auditLogs');

    if (dateFrom != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(dateFrom),
      );
    }

    if (dateTo != null) {
      query = query.where(
        'createdAt',
        isLessThanOrEqualTo: Timestamp.fromDate(dateTo),
      );
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    final snapshot = await query.get();

    var logs = snapshot.docs.map(AuditLog.fromFirestore).toList();

    if (category.isNotEmpty) {
      logs = logs.where((log) => log.category == category).toList();
    }

    if (action.isNotEmpty) {
      logs = logs.where((log) => log.action == action).toList();
    }

    if (actorRole.isNotEmpty) {
      logs = logs.where((log) => log.actorRole == actorRole).toList();
    }

    final normalizedQuery = searchQuery.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return logs;
    }

    return logs.where((log) {
      final searchableText = [
        log.actorName,
        log.actorEmail,
        log.actorRole,
        log.targetUserName,
        log.targetUserEmail,
        log.title,
        log.description,
        log.category,
        log.action,
      ].join(' ').toLowerCase();

      return searchableText.contains(normalizedQuery);
    }).toList();
  }
}
