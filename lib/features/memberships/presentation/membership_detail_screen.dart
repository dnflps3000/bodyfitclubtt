import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../data/membership_service.dart';
import '../domain/membership.dart';

class MembershipDetailScreen extends StatefulWidget {
  const MembershipDetailScreen({
    super.key,
    required this.membership,
    required this.isAdmin,
  });

  final Membership membership;
  final bool isAdmin;

  @override
  State<MembershipDetailScreen> createState() => _MembershipDetailScreenState();
}

class _MembershipDetailScreenState extends State<MembershipDetailScreen> {
  final MembershipService _membershipService = MembershipService();

  late final TextEditingController _entriesRemainingController;
  late String _selectedStatus;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _entriesRemainingController = TextEditingController(
      text: widget.membership.entriesRemaining?.toString() ?? '',
    );

    _selectedStatus = widget.membership.status;
  }

  @override
  void dispose() {
    _entriesRemainingController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day.$month.$year';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  Widget _buildUsageCard({
    required BuildContext context,
    required String title,
    required String emptyText,
    required List<MembershipUsageItem> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(emptyText)
            else
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fitness_center_outlined, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_formatDateTime(item.startTime)} – '
                          '${item.trainingName}',
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return AppTexts.membershipStatusActive;
      case 'inactive':
        return AppTexts.membershipStatusInactive;
      case 'cancelled':
        return AppTexts.membershipStatusCancelled;
      default:
        return status;
    }
  }

  Future<void> _saveAdminChanges() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final entriesRemainingText = _entriesRemainingController.text.trim();
    final entriesRemaining = entriesRemainingText.isEmpty
        ? null
        : int.tryParse(entriesRemainingText);

    if (widget.membership.entriesTotal != null && entriesRemaining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.invalidRemainingEntries)),
      );
      return;
    }

    if (entriesRemaining != null && entriesRemaining < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.invalidRemainingEntries)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _membershipService.updateMembershipByAdmin(
        membership: widget.membership,
        entriesRemaining: entriesRemaining,
        status: _selectedStatus,
        currentUser: currentUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.membershipUpdated)));

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.membershipUpdateError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _cancelReservedReservations() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.cancelAllocatedReservations),
          content: const Text(AppTexts.cancelAllocatedReservationsQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppTexts.cancelReservations),
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
      final count = await _membershipService
          .cancelReservedReservationsForMembership(
            membership: widget.membership,
            currentUser: currentUser,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.allocatedReservationsCancelled(count))),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.cancelAllocatedReservationsError),
        ),
      );
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
    final membership = widget.membership;
    final entriesTotal = membership.entriesTotal;
    final entriesReserved = membership.entriesReserved ?? 0;
    final availableEntries = membership.availableEntries;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.membershipDetail)),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.planName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${AppTexts.status}: ${_statusLabel(membership.status)}',
                    ),
                    Text(
                      '${AppTexts.validFrom}: ${_formatDate(membership.validFrom)}',
                    ),
                    Text(
                      '${AppTexts.validUntil}: ${_formatDate(membership.validUntil)}',
                    ),
                    const SizedBox(height: 12),
                    Text('${AppTexts.entriesTotal}: ${entriesTotal ?? '-'}'),
                    Text(
                      '${AppTexts.entriesRemaining}: ${membership.entriesRemaining ?? '-'}',
                    ),
                    Text('${AppTexts.entriesReserved}: $entriesReserved'),
                    Text('${AppTexts.entriesAvailable}: $availableEntries'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<MembershipUsageSummary>(
              future: _membershipService.loadMembershipUsage(membership),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(AppTexts.membershipUsageLoadError),
                    ),
                  );
                }

                final usage = snapshot.data;

                if (usage == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    _buildUsageCard(
                      context: context,
                      title: AppTexts.allocatedReservations,
                      emptyText: AppTexts.noAllocatedReservations,
                      items: usage.allocatedReservations,
                    ),
                    const SizedBox(height: 16),
                    _buildUsageCard(
                      context: context,
                      title: AppTexts.usedEntries,
                      emptyText: AppTexts.noUsedEntries,
                      items: usage.usedEntries,
                    ),
                  ],
                );
              },
            ),
            if (widget.isAdmin) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppTexts.adminMembershipEdit,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: AppTexts.status,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'active',
                            child: Text(AppTexts.membershipStatusActive),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text(AppTexts.membershipStatusInactive),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text(AppTexts.membershipStatusCancelled),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                      if (membership.entriesTotal != null) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _entriesRemainingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: AppTexts.entriesRemaining,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _saveAdminChanges,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(AppTexts.save),
                      ),
                    ],
                  ),
                ),
              ),
              if (entriesReserved > 0) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppTexts.allocatedReservations,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('${AppTexts.entriesReserved}: $entriesReserved'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _isSaving
                              ? null
                              : _cancelReservedReservations,
                          icon: const Icon(Icons.event_busy_outlined),
                          label: const Text(AppTexts.cancelReservations),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
