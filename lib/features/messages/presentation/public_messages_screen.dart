import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
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
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.deleteMessage),
          content: const Text(AppTexts.deleteMessageQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppTexts.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('public_messages')
          .doc(messageId)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.messageDeleted)));
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.messageDeleteError)),
      );
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
    ).showSnackBar(const SnackBar(content: Text(AppTexts.messageSaved)));
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
          appBar: AppBar(title: const Text(AppTexts.news)),
          floatingActionButton: _canCreateMessage(role)
              ? FloatingActionButton.extended(
                  onPressed: () => _openMessageEditor(context),
                  icon: const Icon(Icons.edit),
                  label: const Text(AppTexts.writeMessageShort),
                )
              : null,
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('public_messages')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text(AppTexts.noPublicMessages));
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  24 + MediaQuery.of(context).padding.bottom,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final doc = messages[index];
                  final data = doc.data();

                  final authorId = data['authorId'] as String? ?? '';
                  final text = data['text'] as String? ?? '';
                  final authorLabel = _authorLabel(data);
                  final updatedByLabel = _updatedByLabel(data);

                  final canManage = _canManageMessage(
                    role: role,
                    currentUserId: currentUser?.uid,
                    authorId: authorId,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 14,
                        right: 6,
                        top: 8,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  authorLabel,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              if (canManage)
                                SizedBox(
                                  width: 36,
                                  height: 32,
                                  child: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    itemBuilder: (_) => const [
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
                                        _confirmDeleteMessage(context, doc.id);
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(text),
                          if (updatedByLabel != null) ...[
                            const SizedBox(height: 8),
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
