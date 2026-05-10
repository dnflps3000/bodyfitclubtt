import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/membership_constants.dart';
import '../../../core/theme/app_texts.dart';
import '../../memberships/data/membership_service.dart';
import '../../memberships/domain/membership.dart';
import '../../payment/presentation/payment_screen.dart';
import '../../reservations/presentation/attendance_qr_scanner_screen.dart';
import '../../reservations/presentation/reservation_qr_screen.dart';
import '../../messages/latest_public_message_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onOpenSchedule});

  final VoidCallback onOpenSchedule;

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
          padding: const EdgeInsets.all(16),
          children: [
            if (role == AppRoles.admin || role == AppRoles.trainer) ...[
              _buildQrScannerButton(context, role),
              const SizedBox(height: 12),
              _buildTodayTrainingsCard(),
              const SizedBox(height: 12),
              _buildNewsCard(),
            ] else ...[
              _buildTodayReservationCard(context),
              const SizedBox(height: 12),
              _buildNearestTrainingCard(),
              const SizedBox(height: 12),
              _buildMembershipSummaryCard(),
              const SizedBox(height: 12),
              _buildNewsCard(),
              const SizedBox(height: 20),
              _buildPaymentButtons(context),
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

  Widget _buildTodayTrainingsCard() {
    return FutureBuilder<List<_HomeTrainingSession>>(
      future: _loadTodayTrainingSessions(),
      builder: (context, snapshot) {
        final sessions = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.event_available),
              title: Text(AppTexts.todaysTrainings),
              subtitle: Text(AppTexts.loading),
            ),
          );
        }

        if (sessions.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text(AppTexts.todaysTrainings),
              subtitle: const Text(AppTexts.noTodaysTrainings),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenSchedule,
            ),
          );
        }

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onOpenSchedule,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_available),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppTexts.todaysTrainings,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final session in sessions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${session.trainingName} - '
                        '${_formatTime(session.startTime)}'
                        ' · ${session.reservedCount}/${session.capacity}',
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

  Widget _buildTodayReservationCard(BuildContext context) {
    return FutureBuilder<_HomeReservation?>(
      future: _loadTodayReservation(),
      builder: (context, snapshot) {
        final reservation = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.event_available),
              title: Text(AppTexts.todayReservations),
              subtitle: Text(AppTexts.loading),
            ),
          );
        }

        if (reservation == null) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.event_available),
              title: Text(AppTexts.todayReservations),
              subtitle: Text(AppTexts.noTodayReservations),
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text(AppTexts.todayReservations),
            subtitle: Text(
              '${reservation.trainingName} - '
              '${_formatTime(reservation.startTime)}\n'
              '${AppTexts.tapToShowQrCode}',
            ),
            trailing: const Icon(Icons.qr_code),
            isThreeLine: true,
            onTap: () {
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
            },
          ),
        );
      },
    );
  }

  Widget _buildNearestTrainingCard() {
    return FutureBuilder<_HomeTrainingSession?>(
      future: _loadNearestTrainingSession(),
      builder: (context, snapshot) {
        final session = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.calendar_month_outlined),
              title: Text(AppTexts.nearestTraining),
              subtitle: Text(AppTexts.loading),
            ),
          );
        }

        if (session == null) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text(AppTexts.nearestTraining),
              subtitle: const Text(AppTexts.noNearestTraining),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenSchedule,
            ),
          );
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text(AppTexts.nearestTraining),
            subtitle: Text(
              '${session.trainingName} - '
              '${_formatNearestTrainingTime(session.startTime)}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenSchedule,
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
          return const Card(
            child: ListTile(
              leading: Icon(Icons.card_membership),
              title: Text(AppTexts.myMemberships),
              subtitle: Text(AppTexts.membershipLoadError),
            ),
          );
        }

        final memberships = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.card_membership),
              title: Text(AppTexts.myMemberships),
              subtitle: Text(AppTexts.loading),
            ),
          );
        }

        if (memberships.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.card_membership),
              title: Text(AppTexts.myMemberships),
              subtitle: Text(AppTexts.noActiveMembership),
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
            title: const Text(AppTexts.myMemberships),
            subtitle: Text(subtitleParts.join('\n')),
            isThreeLine: subtitleParts.length > 2,
          ),
        );
      },
    );
  }

  Widget _buildNewsCard() {
    return const LatestPublicMessageCard();
  }

  Widget _buildPaymentButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentScreen(
                  purchaseCategory: MembershipPurchaseCategories.membership,
                ),
              ),
            );
          },
          icon: const Icon(Icons.card_membership),
          label: const Text(AppTexts.buyMembership),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentScreen(
                  purchaseCategory: MembershipPurchaseCategories.singleEntry,
                  preselectedPlanId: MembershipPlanIds.singleEntry,
                ),
              ),
            );
          },
          icon: const Icon(Icons.confirmation_number_outlined),
          label: const Text(AppTexts.buySingleEntry),
        ),
      ],
    );
  }

  Future<_HomeReservation?> _loadTodayReservation() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return null;
    }

    final firestore = FirebaseFirestore.instance;

    final reservationSnapshot = await firestore
        .collection('reservations')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'active')
        .where('entryStatus', isEqualTo: 'reserved')
        .get();

    final now = DateTime.now();
    final reservations = <_HomeReservation>[];

    for (final reservationDocument in reservationSnapshot.docs) {
      final reservationData = reservationDocument.data();
      final trainingSessionId =
          reservationData['trainingSessionId'] as String? ?? '';

      if (trainingSessionId.isEmpty) {
        continue;
      }

      final sessionDocument = await firestore
          .collection('trainingSessions')
          .doc(trainingSessionId)
          .get();

      final sessionData = sessionDocument.data();

      if (sessionData == null) {
        continue;
      }

      final startTime =
          (sessionData['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      final endTime =
          (sessionData['endTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (!_isSameDate(startTime, now) || endTime.isBefore(now)) {
        continue;
      }

      final trainingTypeId = sessionData['trainingTypeId'] as String? ?? '';

      final trainingTypeDocument = await firestore
          .collection('trainingTypes')
          .doc(trainingTypeId)
          .get();

      final trainingTypeData = trainingTypeDocument.data();

      reservations.add(
        _HomeReservation(
          reservationId: reservationDocument.id,
          trainingSessionId: trainingSessionId,
          trainingName: trainingTypeData?['name'] as String? ?? 'Tréning',
          startTime: startTime,
          endTime: endTime,
        ),
      );
    }

    reservations.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (reservations.isEmpty) {
      return null;
    }

    return reservations.first;
  }

  Future<_HomeTrainingSession?> _loadNearestTrainingSession() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    final sessionSnapshot = await firestore
        .collection('trainingSessions')
        .where('isActive', isEqualTo: true)
        .where('status', isEqualTo: 'scheduled')
        .get();

    final sessions = <_HomeTrainingSession>[];

    for (final sessionDocument in sessionSnapshot.docs) {
      final sessionData = sessionDocument.data();

      final startTime =
          (sessionData['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      final endTime =
          (sessionData['endTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (endTime.isBefore(now)) {
        continue;
      }

      final trainingTypeId = sessionData['trainingTypeId'] as String? ?? '';

      final trainingTypeDocument = await firestore
          .collection('trainingTypes')
          .doc(trainingTypeId)
          .get();

      final trainingTypeData = trainingTypeDocument.data();

      sessions.add(
        _HomeTrainingSession(
          trainingName: trainingTypeData?['name'] as String? ?? 'Tréning',
          startTime: startTime,
          capacity: sessionData['capacity'] as int? ?? 0,
          reservedCount: sessionData['reservedCount'] as int? ?? 0,
        ),
      );
    }

    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (sessions.isEmpty) {
      return null;
    }

    return sessions.first;
  }

  Future<List<_HomeTrainingSession>> _loadTodayTrainingSessions() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    final sessionSnapshot = await firestore
        .collection('trainingSessions')
        .where('isActive', isEqualTo: true)
        .where('status', isEqualTo: 'scheduled')
        .get();

    final sessions = <_HomeTrainingSession>[];

    for (final sessionDocument in sessionSnapshot.docs) {
      final sessionData = sessionDocument.data();

      final startTime =
          (sessionData['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();

      if (!_isSameDate(startTime, now)) {
        continue;
      }

      final trainingTypeId = sessionData['trainingTypeId'] as String? ?? '';

      final trainingTypeDocument = await firestore
          .collection('trainingTypes')
          .doc(trainingTypeId)
          .get();

      final trainingTypeData = trainingTypeDocument.data();

      sessions.add(
        _HomeTrainingSession(
          trainingName: trainingTypeData?['name'] as String? ?? 'Tréning',
          startTime: startTime,
          capacity: sessionData['capacity'] as int? ?? 0,
          reservedCount: sessionData['reservedCount'] as int? ?? 0,
        ),
      );
    }

    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));

    return sessions;
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
      return 'dnes ${_formatTime(dateTime)}';
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (_isSameDate(dateTime, tomorrow)) {
      return 'zajtra ${_formatTime(dateTime)}';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$day.$month. ${_formatTime(dateTime)}';
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
