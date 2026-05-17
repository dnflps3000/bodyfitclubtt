import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../data/admin_discount_service.dart';

class DiscountRequestsScreen extends StatefulWidget {
  const DiscountRequestsScreen({super.key});

  @override
  State<DiscountRequestsScreen> createState() => _DiscountRequestsScreenState();
}

class _DiscountRequestsScreenState extends State<DiscountRequestsScreen> {
  final AdminDiscountService _service = AdminDiscountService();
  bool _isSaving = false;

  String _discountTypeLabel(String type) {
    switch (type) {
      case 'student':
        return AppTexts.discountTypeStudent;
      case 'senior':
        return AppTexts.discountTypeSenior;
      case 'ztp':
        return AppTexts.discountTypeZtp;
      case 'individual':
        return AppTexts.discountTypeIndividual;
      default:
        return type;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return AppTexts.unknownDate;
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day.$month.$year';
  }

  Future<void> _approveRequest({
    required String requestId,
    required String userId,
    required String requestedType,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    DateTime? selectedDate;
    var adminNote = '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: const Text(AppTexts.approveDiscount),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppTexts.selectDiscountValidUntil),
                    subtitle: Text(
                      selectedDate == null
                          ? AppTexts.discountValidUntilRequired
                          : _formatDate(selectedDate!),
                    ),
                    trailing: const Icon(Icons.calendar_month_outlined),
                    onTap: () async {
                      final now = DateTime.now();

                      final pickedDate = await showDatePicker(
                        context: dialogContext,
                        initialDate: DateTime(now.year, now.month + 1, now.day),
                        firstDate: now,
                        lastDate: DateTime(now.year + 5),
                      );

                      if (pickedDate == null) return;

                      setDialogState(() {
                        selectedDate = pickedDate;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: AppTexts.discountAdminNote,
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) {
                      adminNote = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text(AppTexts.cancel),
                ),
                FilledButton(
                  onPressed: selectedDate == null
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(true);
                        },
                  child: const Text(AppTexts.approveDiscount),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || selectedDate == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _service.approveDiscountRequest(
        requestId: requestId,
        userId: userId,
        discountType: requestedType,
        validUntil: selectedDate!,
        adminNote: adminNote,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.discountApproved)),
      );
    } catch (_) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.discountDecisionError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _rejectRequest({
    required String requestId,
    required String userId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    var adminNote = '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text(AppTexts.rejectDiscount),
          content: TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: AppTexts.discountAdminNote,
              alignLabelWithHint: true,
            ),
            onChanged: (value) {
              adminNote = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(AppTexts.rejectDiscount),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _service.rejectDiscountRequest(
        requestId: requestId,
        userId: userId,
        adminNote: adminNote,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.discountRejected)),
      );
    } catch (_) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.discountDecisionError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _openDocumentPreview(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text(AppTexts.discountDocumentPreview)),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.discountRequests),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.watchPendingDiscountRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(AppTexts.discountRequestsLoadError),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.screenPadding),
                child: Text(AppTexts.noDiscountRequests),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: requests.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: AppSpacing.cardGap);
            },
            itemBuilder: (context, index) {
              final request = requests[index];
              final data = request.data();

              final userId = data['userId'] as String? ?? '';
              final userName = data['userName'] as String? ?? AppTexts.unknownUser;
              final userEmail = data['userEmail'] as String? ?? '';
              final requestedType = data['requestedType'] as String? ?? '';
              final note = data['note'] as String? ?? '';
              final imageUrl = data['documentImageUrl'] as String? ?? '';
              final createdAt =
                  (data['createdAt'] as Timestamp?)?.toDate();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (userEmail.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(userEmail),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text('${AppTexts.discountType}: ${_discountTypeLabel(requestedType)}'),
                      Text('${AppTexts.requestedAt}: ${_formatDateTime(createdAt)}'),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text('${AppTexts.reason}: $note'),
                      ],
                      if (imageUrl.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.cardGap),
                        OutlinedButton.icon(
                          onPressed: () {
                            _openDocumentPreview(context, imageUrl);
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: const Text(AppTexts.discountDocumentPreview),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.cardGap),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => _rejectRequest(
                                        requestId: request.id,
                                        userId: userId,
                                      ),
                              child: const Text(AppTexts.rejectDiscount),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => _approveRequest(
                                        requestId: request.id,
                                        userId: userId,
                                        requestedType: requestedType,
                                      ),
                              child: const Text(AppTexts.approveDiscount),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}