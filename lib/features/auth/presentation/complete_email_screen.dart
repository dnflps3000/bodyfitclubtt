import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../audit/data/audit_log_service.dart';

class CompleteEmailScreen extends StatefulWidget {
  const CompleteEmailScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<CompleteEmailScreen> createState() => _CompleteEmailScreenState();
}

class _CompleteEmailScreenState extends State<CompleteEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuditLogService _auditLogService = AuditLogService();

  bool _isSaving = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  Future<void> _saveEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.invalidEmailFormat)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'emailSource': 'manual',
        'emailVerified': false,
        'emailUpdatedBy': user.uid,
        'emailUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _auditLogService.createLogWithUsers(
        category: 'user',
        action: 'user_email_completed',
        targetType: 'user',
        targetId: user.uid,
        targetUserId: user.uid,
        actor: user,
        title: AppTexts.auditUserEmailCompletedTitle,
        description: AppTexts.auditUserEmailCompletedDescription,
        changes: {
          'email': {'oldValue': null, 'newValue': email},
          'emailSource': {'oldValue': 'missing', 'newValue': 'manual'},
          'emailVerified': {'oldValue': false, 'newValue': false},
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.emailSaved)));

      widget.onCompleted?.call();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.emailSaveError)));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.completeEmailTitle),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const Text(AppTexts.completeEmailDescription),
          const SizedBox(height: AppSpacing.sectionGap),
          TextField(
            controller: _emailController,
            enabled: !_isSaving,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: AppTexts.email,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              if (!_isSaving) {
                _saveEmail();
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveEmail,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.email_outlined),
            label: const Text(AppTexts.save),
          ),
        ],
      ),
    );
  }
}
