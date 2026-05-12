import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../../audit/data/audit_log_service.dart';

class EditPublicMessageScreen extends StatefulWidget {
  const EditPublicMessageScreen({super.key, this.messageId, this.initialText});

  final String? messageId;
  final String? initialText;

  @override
  State<EditPublicMessageScreen> createState() =>
      _EditPublicMessageScreenState();
}

class _EditPublicMessageScreenState extends State<EditPublicMessageScreen> {
  late final TextEditingController _textController;
  final AuditLogService _auditLogService = AuditLogService();
  bool _isSaving = false;

  bool get _isEdit => widget.messageId != null;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _fallbackName(User user) {
    final displayName = user.displayName?.trim() ?? '';

    if (displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim() ?? '';

    if (email.isNotEmpty) {
      return email;
    }

    return AppTexts.userFallback;
  }

  Future<void> _saveMessage() async {
    final text = _textController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (text.isEmpty || user == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final role = userData?['role'] as String? ?? '';
      final publicName = userData?['publicName'] as String? ?? '';
      final displayName = userData?['displayName'] as String? ?? '';

      final name = publicName.trim().isNotEmpty
          ? publicName.trim()
          : displayName.trim().isNotEmpty
          ? displayName.trim()
          : _fallbackName(user);

      if (role != AppRoles.admin && role != AppRoles.trainer) {
        if (!mounted) return;
        Navigator.of(context).pop(false);
        return;
      }

      if (_isEdit) {
        final messageRef = FirebaseFirestore.instance
            .collection('public_messages')
            .doc(widget.messageId);

        final oldText = widget.initialText ?? '';

        await messageRef.update({
          'text': text,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': user.uid,
          'updatedByName': name,
          'updatedByRole': role,
        });

        await _auditLogService.createLogWithUsers(
          category: 'message',
          action: 'public_message_updated',
          targetType: 'public_message',
          targetId: widget.messageId ?? '',
          targetUserId: user.uid,
          actor: user,
          title: AppTexts.auditPublicMessageUpdatedTitle,
          description: AppTexts.auditPublicMessageUpdatedDescription,
          changes: {
            'text': {'oldValue': oldText, 'newValue': text},
          },
        );
      } else {
        final messageRef = await FirebaseFirestore.instance
            .collection('public_messages')
            .add({
              'text': text,
              'authorId': user.uid,
              'authorName': name,
              'authorRole': role,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

        await _auditLogService.createLogWithUsers(
          category: 'message',
          action: 'public_message_created',
          targetType: 'public_message',
          targetId: messageRef.id,
          targetUserId: user.uid,
          actor: user,
          title: AppTexts.auditPublicMessageCreatedTitle,
          description: AppTexts.auditPublicMessageCreatedDescription,
          changes: {
            'text': {'oldValue': null, 'newValue': text},
          },
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.messageSaveError)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? AppTexts.editMessage : AppTexts.writeMessage;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              minLines: 8,
              maxLines: 14,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: AppTexts.messageText,
                hintText: AppTexts.messageHint,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveMessage,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                _isEdit ? AppTexts.updateMessage : AppTexts.sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
