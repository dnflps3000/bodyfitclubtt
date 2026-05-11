import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLog {
  const AuditLog({
    required this.id,
    required this.category,
    required this.action,
    required this.actorId,
    required this.actorName,
    required this.actorEmail,
    required this.actorRole,
    required this.targetType,
    required this.targetId,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetUserEmail,
    required this.title,
    required this.description,
    required this.changes,
    required this.createdAt,
  });

  final String id;
  final String category;
  final String action;

  final String actorId;
  final String actorName;
  final String actorEmail;
  final String actorRole;

  final String targetType;
  final String targetId;
  final String targetUserId;
  final String targetUserName;
  final String targetUserEmail;

  final String title;
  final String description;
  final Map<String, dynamic> changes;

  final DateTime? createdAt;

  factory AuditLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return AuditLog(
      id: document.id,
      category: data['category'] as String? ?? '',
      action: data['action'] as String? ?? '',
      actorId: data['actorId'] as String? ?? '',
      actorName: data['actorName'] as String? ?? '',
      actorEmail: data['actorEmail'] as String? ?? '',
      actorRole: data['actorRole'] as String? ?? '',
      targetType: data['targetType'] as String? ?? '',
      targetId: data['targetId'] as String? ?? '',
      targetUserId: data['targetUserId'] as String? ?? '',
      targetUserName: data['targetUserName'] as String? ?? '',
      targetUserEmail: data['targetUserEmail'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      changes: Map<String, dynamic>.from(data['changes'] as Map? ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
