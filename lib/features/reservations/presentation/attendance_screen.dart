import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../../core/widgets/day_card_selector.dart';
import '../data/reservation_service.dart';
import 'attendance_qr_scanner_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, this.trainerId});

  final String? trainerId;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ReservationService _reservationService = ReservationService();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<_AttendanceReservation?> _loadAttendanceReservation(
    QueryDocumentSnapshot<Map<String, dynamic>> reservationDocument,
  ) async {
    final reservationData = reservationDocument.data();

    final trainingSessionId =
        reservationData['trainingSessionId'] as String? ?? '';
    final userId = reservationData['userId'] as String? ?? '';

    final denormalizedTrainingName =
        reservationData['trainingName'] as String? ?? '';
    final denormalizedUserName = reservationData['userName'] as String? ?? '';
    final denormalizedUserEmail = reservationData['userEmail'] as String? ?? '';
    final denormalizedTrainerId = reservationData['trainerId'] as String? ?? '';
    final denormalizedStartTime =
        (reservationData['trainingStartTime'] as Timestamp?)?.toDate();
    final denormalizedEndTime =
        (reservationData['trainingEndTime'] as Timestamp?)?.toDate();

    if (trainingSessionId.isNotEmpty &&
        denormalizedTrainingName.isNotEmpty &&
        denormalizedUserName.isNotEmpty &&
        denormalizedStartTime != null &&
        denormalizedEndTime != null) {
      if (widget.trainerId != null &&
          denormalizedTrainerId != widget.trainerId) {
        return null;
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      if (denormalizedEndTime.isBefore(todayStart)) {
        return null;
      }

      if (!_isSameDate(denormalizedStartTime, _selectedDate)) {
        return null;
      }

      return _AttendanceReservation(
        reservationId: reservationDocument.id,
        trainingSessionId: trainingSessionId,
        userName: denormalizedUserName,
        userEmail: denormalizedUserEmail,
        trainingName: denormalizedTrainingName,
        startTime: denormalizedStartTime,
        endTime: denormalizedEndTime,
      );
    }

    if (trainingSessionId.isEmpty || userId.isEmpty) {
      return null;
    }

    final firestore = FirebaseFirestore.instance;

    final sessionDocument = await firestore
        .collection('trainingSessions')
        .doc(trainingSessionId)
        .get();

    final userDocument = await firestore.collection('users').doc(userId).get();

    final sessionData = sessionDocument.data();
    final userData = userDocument.data();

    if (sessionData == null || userData == null) {
      return null;
    }

    final trainerId = sessionData['trainerId'] as String? ?? '';

    if (widget.trainerId != null && trainerId != widget.trainerId) {
      return null;
    }

    final trainingTypeId = sessionData['trainingTypeId'] as String? ?? '';

    final trainingTypeDocument = await firestore
        .collection('trainingTypes')
        .doc(trainingTypeId)
        .get();

    final trainingTypeData = trainingTypeDocument.data();

    final startTime =
        (sessionData['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();

    final endTime =
        (sessionData['endTime'] as Timestamp?)?.toDate() ?? DateTime.now();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    if (endTime.isBefore(todayStart)) {
      return null;
    }

    if (!_isSameDate(startTime, _selectedDate)) {
      return null;
    }

    final firstName = userData['firstName'] as String? ?? '';
    final lastName = userData['lastName'] as String? ?? '';
    final displayName = userData['displayName'] as String? ?? '';
    final email = userData['email'] as String? ?? '';

    final fullName = '$firstName $lastName'.trim();

    return _AttendanceReservation(
      reservationId: reservationDocument.id,
      trainingSessionId: trainingSessionId,
      userName: fullName.isNotEmpty
          ? fullName
          : displayName.isNotEmpty
          ? displayName
          : email,
      userEmail: email,
      trainingName:
          trainingTypeData?['name'] as String? ?? AppTexts.unknownTraining,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<List<_AttendanceReservation>> _loadAttendanceReservations(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> reservationDocuments,
  ) async {
    final loadedReservations = await Future.wait(
      reservationDocuments.map(_loadAttendanceReservation),
    );

    final reservations = loadedReservations
        .whereType<_AttendanceReservation>()
        .toList();

    reservations.sort((a, b) => a.startTime.compareTo(b.startTime));

    return reservations;
  }

  Future<void> _confirmMarkAttendance(
    _AttendanceReservation reservation,
    bool attended,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            attended ? AppTexts.markAttendedTitle : AppTexts.markNoShowTitle,
          ),
          content: Text(
            '${attended ? AppTexts.markAttendedQuestion : AppTexts.markNoShowQuestion}\n\n'
            '${reservation.userName}\n'
            '${reservation.trainingName}\n'
            '${_formatDateTime(reservation.startTime)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(attended ? AppTexts.attended : AppTexts.noShow),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _reservationService.markReservationAttendance(
        reservationId: reservation.reservationId,
        trainingSessionId: reservation.trainingSessionId,
        attended: attended,
        trainerId: widget.trainerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.attendanceMarked)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.attendanceMarkError)),
      );
    }
  }

  Future<void> _openQrScanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceQrScannerScreen(trainerId: widget.trainerId),
      ),
    );
  }

  Widget _buildReservationCard(_AttendanceReservation reservation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.userName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (reservation.userEmail.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(reservation.userEmail),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(reservation.trainingName),
            const SizedBox(height: AppSpacing.xs),
            Text(_formatDateTime(reservation.startTime)),
            const SizedBox(height: AppSpacing.sectionGap),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmMarkAttendance(reservation, true),
                    icon: const Icon(Icons.check),
                    label: const Text(AppTexts.attended),
                  ),
                ),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmMarkAttendance(reservation, false),
                    icon: const Icon(Icons.close),
                    label: const Text(AppTexts.noShow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    final days = _nextSevenDays();

    return DayCardSelector(
      key: const PageStorageKey('attendance-day-selector'),
      days: days,
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  List<DateTime> _nextSevenDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (index) {
      return today.add(Duration(days: index));
    });
  }

  Widget _buildEmptyAttendanceState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          AppTexts.noActiveReservationsForAttendance,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateStart = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final selectedDateEnd = selectedDateStart.add(const Duration(days: 1));

    Query<Map<String, dynamic>> reservationsQuery = FirebaseFirestore.instance
        .collection('reservations')
        .where('status', isEqualTo: 'active')
        .where('entryStatus', isEqualTo: 'reserved')
        .where(
          'trainingStartTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDateStart),
        )
        .where(
          'trainingStartTime',
          isLessThan: Timestamp.fromDate(selectedDateEnd),
        );

    if (widget.trainerId != null) {
      reservationsQuery = reservationsQuery.where(
        'trainerId',
        isEqualTo: widget.trainerId,
      );
    }

    final reservationsStream = reservationsQuery
        .orderBy('trainingStartTime')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.attendance),
        actions: [
          IconButton(
            tooltip: AppTexts.scanQrCode,
            onPressed: _openQrScanner,
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: reservationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppTexts.attendanceLoadError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservationDocuments = snapshot.data?.docs ?? [];

          return Column(
            children: [
              _buildDateFilter(),
              Expanded(
                child: reservationDocuments.isEmpty
                    ? _buildEmptyAttendanceState()
                    : FutureBuilder<List<_AttendanceReservation>>(
                        future: _loadAttendanceReservations(
                          reservationDocuments,
                        ),
                        builder: (context, detailSnapshot) {
                          if (detailSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (detailSnapshot.hasError) {
                            return const Center(
                              child: Text(AppTexts.attendanceLoadError),
                            );
                          }

                          final reservations = detailSnapshot.data ?? [];

                          if (reservations.isEmpty) {
                            return _buildEmptyAttendanceState();
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.all(
                              AppSpacing.screenPadding,
                            ),
                            itemCount: reservations.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.cardGap),
                            itemBuilder: (context, index) {
                              return _buildReservationCard(reservations[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AttendanceReservation {
  const _AttendanceReservation({
    required this.reservationId,
    required this.trainingSessionId,
    required this.userName,
    required this.userEmail,
    required this.trainingName,
    required this.startTime,
    required this.endTime,
  });

  final String reservationId;
  final String trainingSessionId;
  final String userName;
  final String userEmail;
  final String trainingName;
  final DateTime startTime;
  final DateTime endTime;
}
