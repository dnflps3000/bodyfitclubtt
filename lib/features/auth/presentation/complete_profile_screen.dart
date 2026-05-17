import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../audit/data/audit_log_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final AuditLogService _auditLogService = AuditLogService();

  bool _loading = false;

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) return;

    setState(() => _loading = true);

    final displayName = "$firstName $lastName";

    // update Firebase Auth (displayName)
    await user.updateDisplayName(displayName);

    // uloženie do Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'publicName': firstName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _auditLogService.createLogWithUsers(
      category: 'profile',
      action: 'profile_completed',
      targetType: 'user',
      targetId: user.uid,
      targetUserId: user.uid,
      actor: user,
      title: AppTexts.auditProfileCompletedTitle,
      description: AppTexts.auditProfileCompletedDescription,
      changes: {
        'firstName': {'oldValue': null, 'newValue': firstName},
        'lastName': {'oldValue': null, 'newValue': lastName},
        'displayName': {'oldValue': null, 'newValue': displayName},
        'publicName': {'oldValue': null, 'newValue': firstName},
      },
    );

    if (!mounted) return;

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.completeProfileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: AppTexts.firstName),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: AppTexts.lastName),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _loading ? null : _saveProfile,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppTexts.save),
            ),
          ],
        ),
      ),
    );
  }
}
