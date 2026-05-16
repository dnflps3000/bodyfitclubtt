import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
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
  late Future<MembershipUsageSummary> _usageFuture;

  bool _isSaving = false;
  int? _entriesReservedOverride;
  int? _entriesRemainingOverride;

  @override
  void initState() {
    super.initState();

    _entriesRemainingController = TextEditingController(
      text: widget.membership.entriesRemaining?.toString() ?? '',
    );

    _selectedStatus = widget.membership.status;
    _usageFuture = _membershipService.loadMembershipUsage(widget.membership);
  }

  @override
  void dispose() {
    _entriesRemainingController.dispose();
    super.dispose();
  }

  void _reloadUsage() {
    _usageFuture = _membershipService.loadMembershipUsage(widget.membership);
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

  String _currentMembershipDisplayStatusLabel({required int availableEntries}) {
    if (_selectedStatus == 'cancelled') {
      return AppTexts.membershipStatusCancelled;
    }

    if (_selectedStatus == 'inactive') {
      return AppTexts.membershipStatusInactive;
    }

    if (widget.membership.validFrom != null &&
        DateTime.now().isBefore(widget.membership.validFrom!)) {
      return AppTexts.membershipStatusNotYetValid;
    }

    if (widget.membership.validUntil != null &&
        DateTime.now().isAfter(widget.membership.validUntil!)) {
      return AppTexts.membershipStatusExpired;
    }

    if (widget.membership.entriesTotal != null && availableEntries <= 0) {
      return AppTexts.membershipStatusUsedUp;
    }

    return AppTexts.membershipStatusActive;
  }

  Widget _buildUsageCard({
    required BuildContext context,
    required String title,
    required String emptyText,
    required List<MembershipUsageItem> items,
    bool canCancelItems = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.cardGap),
            if (items.isEmpty)
              Text(emptyText)
            else ...[
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.fitness_center_outlined, size: 20),
                      const SizedBox(width: AppSpacing.smallIconTextGap),
                      Expanded(
                        child: Text(
                          '${_formatDateTime(item.startTime)} – '
                          '${item.trainingName}',
                        ),
                      ),
                      if (canCancelItems) ...[
                        const SizedBox(width: AppSpacing.smallIconTextGap),
                        TextButton(
                          onPressed: _isSaving
                              ? null
                              : () => _cancelReservedReservation(item),
                          child: const Text(AppTexts.cancel),
                        ),
                      ],
                    ],
                  ),
                ),
              if (canCancelItems) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _cancelReservedReservations,
                    icon: const Icon(Icons.event_busy_outlined),
                    label: const Text(AppTexts.cancelAllReservations),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
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

    final entriesTotal = widget.membership.entriesTotal;
    final entriesReserved =
        _entriesReservedOverride ?? (widget.membership.entriesReserved ?? 0);

    if (entriesTotal != null && entriesRemaining == null) {
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

    if (entriesTotal != null &&
        entriesRemaining != null &&
        entriesRemaining > entriesTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.invalidRemainingEntriesHigherThanTotal),
        ),
      );
      return;
    }

    if (entriesRemaining != null && entriesReserved > entriesRemaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.invalidRemainingEntriesLowerThanReserved),
        ),
      );
      return;
    }

    final isDeactivatingMembership =
        _selectedStatus == 'inactive' || _selectedStatus == 'cancelled';

    if (isDeactivatingMembership && entriesReserved > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.cancelReservationsBeforeDeactivation),
        ),
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

      setState(() {
        _entriesRemainingOverride = entriesRemaining;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.membershipUpdated)));
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
              child: const Text(AppTexts.back),
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

      setState(() {
        _entriesReservedOverride = 0;
        _reloadUsage();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.allocatedReservationsCancelled(count))),
      );
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

  Future<void> _cancelReservedReservation(
    MembershipUsageItem reservation,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.cancelReservationForMembership),
          content: const Text(AppTexts.cancelReservationForMembershipQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.back),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppTexts.cancelReservation),
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
      await _membershipService.cancelReservedReservationForMembership(
        membership: widget.membership,
        reservation: reservation,
        currentUser: currentUser,
      );

      if (!mounted) return;

      final currentEntriesReserved =
          _entriesReservedOverride ?? (widget.membership.entriesReserved ?? 0);

      setState(() {
        _entriesReservedOverride = currentEntriesReserved > 0
            ? currentEntriesReserved - 1
            : 0;
        _reloadUsage();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.reservationForMembershipCancelled),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.reservationCancelError)),
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
    final entriesReserved =
        _entriesReservedOverride ?? (membership.entriesReserved ?? 0);

    final entriesRemainingValue =
        _entriesRemainingOverride ?? membership.entriesRemaining;

    final entriesRemainingForCalculation = entriesRemainingValue ?? 0;

    final availableEntries = membership.entriesTotal == null
        ? membership.availableEntries
        : entriesRemainingForCalculation - entriesReserved < 0
        ? 0
        : entriesRemainingForCalculation - entriesReserved;

    final displayStatusLabel = _currentMembershipDisplayStatusLabel(
      availableEntries: availableEntries,
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.membershipDetail)),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.planName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    Text('${AppTexts.status}: $displayStatusLabel'),
                    Text(
                      '${AppTexts.validFrom}: ${_formatDate(membership.validFrom)}',
                    ),
                    Text(
                      '${AppTexts.validUntil}: ${_formatDate(membership.validUntil)}',
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    Text('${AppTexts.entriesTotal}: ${entriesTotal ?? '-'}'),
                    Text(
                      '${AppTexts.entriesRemaining}: ${entriesRemainingValue ?? '-'}',
                    ),
                    Text('${AppTexts.entriesReserved}: $entriesReserved'),
                    Text('${AppTexts.entriesAvailable}: $availableEntries'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            FutureBuilder<MembershipUsageSummary>(
              future: _usageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.cardPadding),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.cardPadding),
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
                      canCancelItems: widget.isAdmin,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
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
              const SizedBox(height: AppSpacing.sectionGap),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppTexts.adminMembershipEdit,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.cardGap),
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
                        const SizedBox(height: AppSpacing.cardGap),
                        TextField(
                          controller: _entriesRemainingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: AppTexts.entriesRemaining,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sectionGap),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _saveAdminChanges,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text(AppTexts.save),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
