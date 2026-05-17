import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';

class AccountDeletionRequestsScreen extends StatefulWidget {
  const AccountDeletionRequestsScreen({super.key});

  @override
  State<AccountDeletionRequestsScreen> createState() =>
      _AccountDeletionRequestsScreenState();
}

class _AccountDeletionRequestsScreenState
    extends State<AccountDeletionRequestsScreen> {
  bool _isCompleting = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> _watchRequests() {
    return FirebaseFirestore.instance
        .collection('accountDeletionRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots();
  }

  Future<void> _completeRequest({
    required String uid,
    required String displayLabel,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppTexts.completeAccountDeletionTitle),
          content: Text(
            '${AppTexts.completeAccountDeletionQuestion}\n\n'
            '$displayLabel',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppTexts.completeAccountDeletion),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      ).httpsCallable('completeAccountDeletionRequest');

      await callable.call({'uid': uid});

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text(AppTexts.accountDeletionCompleted)),
      );
    } catch (_) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text(AppTexts.accountDeletionCompleteError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return AppTexts.unknownDate;
    }

    final date = timestamp.toDate();

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _displayLabel(Map<String, dynamic> data) {
    final publicName = (data['publicName'] as String? ?? '').trim();
    final displayName = (data['displayName'] as String? ?? '').trim();
    final email = (data['email'] as String? ?? '').trim();

    if (publicName.isNotEmpty) return publicName;
    if (displayName.isNotEmpty) return displayName;
    if (email.isNotEmpty) return email;

    return AppTexts.unknownUser;
  }

  Widget _buildRequestCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final uid = (data['uid'] as String?) ?? doc.id;
    final email = (data['email'] as String? ?? '').trim();
    final reason = (data['reason'] as String? ?? '').trim();
    final requestedAt = data['requestedAt'] as Timestamp?;
    final displayLabel = _displayLabel(data);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayLabel, style: Theme.of(context).textTheme.titleMedium),
            if (email.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(email),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text('${AppTexts.requestedAt}: ${_formatTimestamp(requestedAt)}'),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.cardGap),
              Text('${AppTexts.reason}: $reason'),
            ],
            const SizedBox(height: AppSpacing.cardGap),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isCompleting
                    ? null
                    : () => _completeRequest(
                        uid: uid,
                        displayLabel: displayLabel,
                      ),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: Text(AppTexts.completeAccountDeletion),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.accountDeletionRequests)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _watchRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(AppTexts.accountDeletionRequestsLoadError),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return Center(child: Text(AppTexts.noAccountDeletionRequests));
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: requests.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.cardGap),
            itemBuilder: (context, index) {
              return _buildRequestCard(requests[index]);
            },
          );
        },
      ),
    );
  }
}
