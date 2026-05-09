import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
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

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day.$month.$year';
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  Future<_AttendanceReservation?> _loadAttendanceReservation(
    QueryDocumentSnapshot<Map<String, dynamic>> reservationDocument,
  ) async {
    final reservationData = reservationDocument.data();

    final trainingSessionId =
        reservationData['trainingSessionId'] as String? ?? '';
    final userId = reservationData['userId'] as String? ?? '';

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
      trainingName: trainingTypeData?['name'] as String? ?? 'Tréning',
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<List<_AttendanceReservation>> _loadAttendanceReservations(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> reservationDocuments,
  ) async {
    final reservations = <_AttendanceReservation>[];

    for (final reservationDocument in reservationDocuments) {
      final reservation = await _loadAttendanceReservation(reservationDocument);

      if (reservation != null) {
        reservations.add(reservation);
      }
    }

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.userName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (reservation.userEmail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(reservation.userEmail),
            ],
            const SizedBox(height: 8),
            Text(reservation.trainingName),
            const SizedBox(height: 4),
            Text(_formatDateTime(reservation.startTime)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmMarkAttendance(reservation, true),
                    icon: const Icon(Icons.check),
                    label: const Text(AppTexts.attended),
                  ),
                ),
                const SizedBox(width: 12),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousDay,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Center(
              child: Text(
                _formatDate(_selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: _nextDay,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reservationsStream = FirebaseFirestore.instance
        .collection('reservations')
        .where('status', isEqualTo: 'active')
        .where('entryStatus', isEqualTo: 'reserved')
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
      body: Column(
        children: [
          _buildDateFilter(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: reservationsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(AppTexts.attendanceLoadError),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reservationDocuments = snapshot.data?.docs ?? [];

                if (reservationDocuments.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        AppTexts.noActiveReservationsForAttendance,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return FutureBuilder<List<_AttendanceReservation>>(
                  future: _loadAttendanceReservations(reservationDocuments),
                  builder: (context, detailSnapshot) {
                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (detailSnapshot.hasError) {
                      return const Center(
                        child: Text(AppTexts.attendanceLoadError),
                      );
                    }

                    final reservations = detailSnapshot.data ?? [];

                    if (reservations.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            AppTexts.noActiveReservationsForAttendance,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: reservations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildReservationCard(reservations[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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
