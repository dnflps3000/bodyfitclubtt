import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../../core/utils/localized_firestore_text.dart';
import '../../audit/data/audit_log_service.dart';
import 'edit_public_message_screen.dart';

class PublicMessagesScreen extends StatelessWidget {
  const PublicMessagesScreen({super.key});

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  bool _canCreateMessage(String? role) {
    return role == AppRoles.trainer || role == AppRoles.admin;
  }

  bool _canManageMessage({
    required String? role,
    required String? currentUserId,
    required String authorId,
  }) {
    if (role == AppRoles.admin) {
      return true;
    }

    if (role == AppRoles.trainer && currentUserId == authorId) {
      return true;
    }

    return false;
  }

  String _cleanAuthorName(String name) {
    var cleanedName = name.trim();

    final prefixes = [
      'Admin - ',
      '${AppTexts.roleAdmin} - ',
      '${AppTexts.roleTrainer} - ',
    ];

    for (final prefix in prefixes) {
      if (cleanedName.startsWith(prefix)) {
        cleanedName = cleanedName.replaceFirst(prefix, '').trim();
      }
    }

    return cleanedName;
  }

  String _authorLabel(Map<String, dynamic> data) {
    final storedAuthorName =
        data['authorName'] as String? ?? AppTexts.userFallback;
    final authorName = _cleanAuthorName(storedAuthorName);
    final authorRole = data['authorRole'] as String? ?? '';

    if (authorRole == AppRoles.admin) {
      return '${AppTexts.roleAdmin} - $authorName';
    }

    if (authorRole == AppRoles.trainer) {
      return '${AppTexts.roleTrainer} - $authorName';
    }

    return authorName;
  }

  String? _updatedByLabel(Map<String, dynamic> data) {
    final storedUpdatedByName = data['updatedByName'] as String? ?? '';
    final updatedByName = _cleanAuthorName(storedUpdatedByName);
    final updatedByRole = data['updatedByRole'] as String? ?? '';

    if (updatedByName.trim().isEmpty) {
      return null;
    }

    if (updatedByRole == AppRoles.admin) {
      return '${AppTexts.editedByAdmin} $updatedByName';
    }

    if (updatedByRole == AppRoles.trainer) {
      return '${AppTexts.editedByTrainer} $updatedByName';
    }

    return '${AppTexts.editedBy} $updatedByName';
  }

  Future<void> _confirmDeleteMessage(
    BuildContext context,
    String messageId,
    Map<String, dynamic> messageData,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppTexts.deleteMessage),
          content: Text(AppTexts.deleteMessageQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppTexts.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final oldText = messageData['text'] as String? ?? '';
      final authorId = messageData['authorId'] as String? ?? '';

      await FirebaseFirestore.instance
          .collection('public_messages')
          .doc(messageId)
          .delete();

      await AuditLogService().createLogWithUsers(
        category: 'message',
        action: 'public_message_deleted',
        targetType: 'public_message',
        targetId: messageId,
        targetUserId: authorId,
        actor: currentUser,
        title: AppTexts.auditPublicMessageDeletedTitle,
        description: AppTexts.auditPublicMessageDeletedDescription,
        changes: {
          'text': {'oldValue': oldText, 'newValue': null},
        },
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppTexts.messageDeleted)));
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppTexts.messageDeleteError)));
    }
  }

  Future<void> _openMessageEditor(
    BuildContext context, {
    String? docId,
    String? oldText,
  }) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            EditPublicMessageScreen(messageId: docId, initialText: oldText),
      ),
    );

    if (!context.mounted || saved != true) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppTexts.messageSaved)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getCurrentUserData(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data;
        final role = userData?['role'] as String?;
        final currentUser = FirebaseAuth.instance.currentUser;

        return Scaffold(
          appBar: AppBar(title: Text(AppTexts.news)),
          floatingActionButton: _canCreateMessage(role)
              ? FloatingActionButton.extended(
                  onPressed: () => _openMessageEditor(context),
                  icon: const Icon(Icons.edit),
                  label: Text(AppTexts.writeMessageShort),
                )
              : null,
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('public_messages')
                .orderBy('createdAt', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text(AppTexts.noPublicMessages));
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.messageListHorizontalPadding,
                  AppSpacing.messageListTopPadding,
                  AppSpacing.messageListHorizontalPadding,
                  AppSpacing.messageListBottomPadding +
                      MediaQuery.of(context).padding.bottom,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final doc = messages[index];
                  final data = doc.data();

                  final authorId = data['authorId'] as String? ?? '';
                  final text = LocalizedFirestoreText.resolve(
                    data,
                    field: 'text',
                    localizedField: 'textLocalized',
                  );
                  final authorLabel = _authorLabel(data);
                  final updatedByLabel = _updatedByLabel(data);

                  final canManage = _canManageMessage(
                    role: role,
                    currentUserId: currentUser?.uid,
                    authorId: authorId,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.messageCardLeftPadding,
                        right: AppSpacing.messageCardRightPadding,
                        top: AppSpacing.messageCardTopPadding,
                        bottom: AppSpacing.messageCardBottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  authorLabel,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (canManage)
                                SizedBox(
                                  width: AppSpacing.messageMenuButtonWidth,
                                  height: AppSpacing.messageMenuButtonHeight,
                                  child: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: AppSpacing.messageMenuIconSize,
                                    ),
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(AppTexts.editMessage),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(AppTexts.deleteMessage),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _openMessageEditor(
                                          context,
                                          docId: doc.id,
                                          oldText: text,
                                        );
                                        return;
                                      }

                                      if (value == 'delete') {
                                        _confirmDeleteMessage(
                                          context,
                                          doc.id,
                                          data,
                                        );
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(text),
                          if (updatedByLabel != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              updatedByLabel,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
