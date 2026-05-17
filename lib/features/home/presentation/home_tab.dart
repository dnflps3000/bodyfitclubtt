import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../admin/presentation/account_deletion_requests_screen.dart';
import '../../discounts/presentation/discount_requests_screen.dart';
import '../../memberships/data/membership_service.dart';
import '../../memberships/domain/membership.dart';
import '../../reservations/presentation/attendance_qr_scanner_screen.dart';
import '../../reservations/presentation/reservation_qr_screen.dart';
import '../../messages/presentation/latest_public_message_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.onOpenSchedule,
    this.onOpenReservations,
    this.onOpenMemberships,
  });

  final VoidCallback onOpenSchedule;
  final VoidCallback? onOpenReservations;
  final VoidCallback? onOpenMemberships;

  TextStyle? _homeCardTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: currentUser == null
          ? const Stream.empty()
          : FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final role = data?['role'] as String? ?? AppRoles.user;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            if (role == AppRoles.admin || role == AppRoles.trainer) ...[
              _buildQrScannerButton(context, role),
              const SizedBox(height: AppSpacing.cardGap),
              _buildNearestTrainingsCard(),
              const SizedBox(height: AppSpacing.cardGap),
              _buildNewsCard(),
              if (role == AppRoles.admin) ...[
                const SizedBox(height: AppSpacing.cardGap),
                _buildDiscountRequestsCard(context),
                const SizedBox(height: AppSpacing.cardGap),
                _buildAccountDeletionRequestsCard(context),
              ],
            ] else ...[
              _buildNearestReservationsCard(context),
              const SizedBox(height: AppSpacing.cardGap),
              _buildNearestTrainingsCard(),
              const SizedBox(height: AppSpacing.cardGap),
              _buildMembershipSummaryCard(),
              const SizedBox(height: AppSpacing.cardGap),
              _buildNewsCard(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildQrScannerButton(BuildContext context, String role) {
    return FilledButton.icon(
      onPressed: () => _openAttendanceQrScanner(context, role),
      icon: const Icon(Icons.qr_code_scanner),
      label: const Text(AppTexts.scanQrCodes),
    );
  }

  Widget _buildAccountDeletionRequestsCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('accountDeletionRequests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data?.docs.length ?? 0;

        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: Text(
                AppTexts.accountDeletionRequests,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.accountDeletionRequestsLoadError),
              onTap: () => _openAccountDeletionRequests(context),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: Text(
                AppTexts.accountDeletionRequests,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.loading),
              onTap: () => _openAccountDeletionRequests(context),
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: Text(
              '${AppTexts.accountDeletionRequests} ($pendingCount)',
              style: _homeCardTitleStyle(context),
            ),
            subtitle: Text(
              pendingCount == 0
                  ? AppTexts.noAccountDeletionRequests
                  : AppTexts.accountDeletionRequestsWaiting,
            ),
            onTap: () => _openAccountDeletionRequests(context),
          ),
        );
      },
    );
  }

  Widget _buildDiscountRequestsCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('discount_requests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data?.docs.length ?? 0;

        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.discount_outlined),
              title: Text(
                AppTexts.discountRequests,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.discountRequestsLoadError),
              onTap: () => _openDiscountRequests(context),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.discount_outlined),
              title: Text(
                AppTexts.discountRequests,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.loading),
              onTap: () => _openDiscountRequests(context),
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.discount_outlined),
            title: Text(
              '${AppTexts.discountRequests} ($pendingCount)',
              style: _homeCardTitleStyle(context),
            ),
            subtitle: Text(
              pendingCount == 0
                  ? AppTexts.noDiscountRequests
                  : AppTexts.discountRequestsDescription,
            ),
            onTap: () => _openDiscountRequests(context),
          ),
        );
      },
    );
  }

  Widget _buildNearestTrainingsCard() {
    return FutureBuilder<List<_HomeTrainingSession>>(
      future: _loadNearestTrainingSessions(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(
                AppTexts.nearestTrainings,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.loading),
            ),
          );
        }

        if (sessions.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(
                AppTexts.nearestTrainings,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.noNearestTraining),
              onTap: onOpenSchedule,
            ),
          );
        }

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.cardInnerRadius),
            onTap: onOpenSchedule,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.event_available),
                  const SizedBox(width: AppSpacing.iconTextGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.nearestTrainings,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final session in sessions)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.itemBottomGap,
                            ),
                            child: Text(
                              '${session.trainingName} - '
                              '${_formatNearestTrainingTime(session.startTime)}'
                              ' · ${session.reservedCount}/${session.capacity}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNearestReservationsCard(BuildContext context) {
    return FutureBuilder<List<_HomeReservation>>(
      future: _loadNearestReservations(),
      builder: (context, snapshot) {
        final reservations = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(
                AppTexts.nearestReservations,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.loading),
            ),
          );
        }

        if (reservations.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(
                AppTexts.nearestReservations,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.noNearestReservations),
              onTap: onOpenReservations,
            ),
          );
        }

        final nearestReservation = reservations.first;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.cardInnerRadius),
            onTap: onOpenReservations,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.event_available),
                  const SizedBox(width: AppSpacing.iconTextGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                AppTexts.nearestReservations,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _openReservationQrCode(
                                  context,
                                  nearestReservation,
                                );
                              },
                              icon: const Icon(Icons.qr_code, size: 18),
                              label: const Text(AppTexts.qrShort),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      AppSpacing.compactButtonHorizontalPadding,
                                  vertical:
                                      AppSpacing.compactButtonVerticalPadding,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final reservation in reservations)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.listBottomGap,
                            ),
                            child: Text(
                              '${reservation.trainingName} - '
                              '${_formatNearestTrainingTime(reservation.startTime)}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembershipSummaryCard() {
    return StreamBuilder<List<Membership>>(
      stream: MembershipService().watchMyActiveMemberships(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.card_membership),
              title: Text(
                AppTexts.myMemberships,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.membershipLoadError),
            ),
          );
        }

        final memberships = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.card_membership),
              title: Text(
                AppTexts.myMemberships,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.loading),
            ),
          );
        }

        if (memberships.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.card_membership),
              title: Text(
                AppTexts.myMemberships,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: const Text(AppTexts.noActiveMembership),
              onTap: onOpenMemberships,
            ),
          );
        }

        final entryBasedMemberships = memberships.where((membership) {
          return membership.isEntryBasedMembership;
        }).toList();

        final dailyMemberships = memberships.where((membership) {
          return membership.isDailyMembership;
        }).toList();

        final availableEntries = entryBasedMemberships.fold<int>(
          0,
          (total, membership) => total + membership.availableEntries,
        );

        final reservedEntries = entryBasedMemberships.fold<int>(
          0,
          (total, membership) => total + (membership.entriesReserved ?? 0),
        );

        final subtitleParts = <String>[
          '${AppTexts.activeMembershipsCount}: ${memberships.length}',
        ];

        if (entryBasedMemberships.isNotEmpty) {
          subtitleParts.add(
            '${AppTexts.availableEntriesSummary}: $availableEntries',
          );
        }

        if (reservedEntries > 0) {
          subtitleParts.add(
            '${AppTexts.reservedEntriesSummary}: $reservedEntries',
          );
        }

        if (dailyMemberships.isNotEmpty) {
          subtitleParts.add(
            '${AppTexts.dailyMembershipsSummary}: ${dailyMemberships.length}',
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.card_membership),
            title: Text(
              AppTexts.myMemberships,
              style: _homeCardTitleStyle(context),
            ),
            subtitle: Text(subtitleParts.join('\n')),
            isThreeLine: subtitleParts.length > 2,
            onTap: onOpenMemberships,
          ),
        );
      },
    );
  }

  Widget _buildNewsCard() {
    return const LatestPublicMessageCard();
  }

  Future<List<_HomeReservation>> _loadNearestReservations() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return [];
    }

    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    final reservationSnapshot = await firestore
        .collection('reservations')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'active')
        .where('entryStatus', isEqualTo: 'reserved')
        .where(
          'trainingStartTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(now),
        )
        .orderBy('trainingStartTime')
        .limit(3)
        .get();

    return reservationSnapshot.docs.map((document) {
      final data = document.data();

      final startTime =
          (data['trainingStartTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      final endTime =
          (data['trainingEndTime'] as Timestamp?)?.toDate() ?? startTime;

      return _HomeReservation(
        reservationId: document.id,
        trainingSessionId: data['trainingSessionId'] as String? ?? '',
        trainingName:
            data['trainingName'] as String? ?? AppTexts.unknownTraining,
        startTime: startTime,
        endTime: endTime,
      );
    }).toList();
  }

  Future<List<_HomeTrainingSession>> _loadNearestTrainingSessions() async {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 14));

    final sessionSnapshot = await FirebaseFirestore.instance
        .collection('trainingSessions')
        .where('isActive', isEqualTo: true)
        .where('status', isEqualTo: 'scheduled')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('startTime', isLessThan: Timestamp.fromDate(endDate))
        .orderBy('startTime')
        .limit(3)
        .get();

    return sessionSnapshot.docs.map((sessionDocument) {
      final sessionData = sessionDocument.data();

      final startTime =
          (sessionData['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      return _HomeTrainingSession(
        trainingName:
            sessionData['trainingName'] as String? ?? AppTexts.unknownTraining,
        startTime: startTime,
        capacity: sessionData['capacity'] as int? ?? 0,
        reservedCount: sessionData['reservedCount'] as int? ?? 0,
      );
    }).toList();
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatNearestTrainingTime(DateTime dateTime) {
    final now = DateTime.now();

    if (_isSameDate(dateTime, now)) {
      return '${AppTexts.todayLower} ${_formatTime(dateTime)}';
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (_isSameDate(dateTime, tomorrow)) {
      return '${AppTexts.tomorrowLower} ${_formatTime(dateTime)}';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$day.$month. ${_formatTime(dateTime)}';
  }

  void _openReservationQrCode(
    BuildContext context,
    _HomeReservation reservation,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservationQrScreen(
          reservationId: reservation.reservationId,
          trainingSessionId: reservation.trainingSessionId,
          trainingName: reservation.trainingName,
          startTime: reservation.startTime,
          endTime: reservation.endTime,
        ),
      ),
    );
  }

  Future<void> _openAttendanceQrScanner(
    BuildContext context,
    String role,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceQrScannerScreen(
          trainerId: role == AppRoles.trainer ? currentUser.uid : null,
        ),
      ),
    );
  }

  void _openDiscountRequests(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DiscountRequestsScreen()));
  }

  void _openAccountDeletionRequests(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountDeletionRequestsScreen()),
    );
  }
}

class _HomeReservation {
  const _HomeReservation({
    required this.reservationId,
    required this.trainingSessionId,
    required this.trainingName,
    required this.startTime,
    required this.endTime,
  });

  final String reservationId;
  final String trainingSessionId;
  final String trainingName;
  final DateTime startTime;
  final DateTime endTime;
}

class _HomeTrainingSession {
  const _HomeTrainingSession({
    required this.trainingName,
    required this.startTime,
    required this.capacity,
    required this.reservedCount,
  });

  final String trainingName;
  final DateTime startTime;
  final int capacity;
  final int reservedCount;
}
