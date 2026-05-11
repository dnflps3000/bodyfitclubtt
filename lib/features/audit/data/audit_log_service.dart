import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/audit_log.dart';

class AuditLogService {
  AuditLogService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
    int limit = 100,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('auditLogs')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (action.isNotEmpty) {
      query = query.where('action', isEqualTo: action);
    }

    if (actorRole.isNotEmpty) {
      query = query.where('actorRole', isEqualTo: actorRole);
    }

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

    final snapshot = await query.get();

    final logs = snapshot.docs.map(AuditLog.fromFirestore).toList();

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
