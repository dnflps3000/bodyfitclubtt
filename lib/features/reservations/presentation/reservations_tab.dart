import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../data/reservation_service.dart';
import 'reservation_qr_screen.dart';

/* Zobrazuje budúce aktívne rezervácie aktuálne prihláseného používateľa.
   Primárne používa denormalizované údaje uložené priamo v rezervácii,
   aby sa zbytočne nenačítavali ďalšie dokumenty tréningov a používateľov. */
class ReservationsTab extends StatelessWidget {
  const ReservationsTab({super.key});

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _confirmCancelReservation(
    BuildContext context,
    _ReservationDetail reservation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.cancelReservationTitle),
          content: Text(
            '${AppTexts.cancelReservationQuestion}\n\n'
            '${reservation.trainingName}\n'
            '${_formatDateTime(reservation.startTime)} - '
            '${_formatTime(reservation.endTime)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.cancel),
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

    try {
      await ReservationService().cancelReservation(
        reservationId: reservation.reservationId,
        trainingSessionId: reservation.trainingSessionId,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.reservationCancelled)),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.reservationCancelError)),
      );
    }
  }

  Future<void> _openReservationQrScreen(
    BuildContext context,
    _ReservationDetail reservation,
  ) async {
    await Navigator.of(context).push(
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

  Future<_ReservationDetail?> _loadReservationDetail(
    QueryDocumentSnapshot<Map<String, dynamic>> reservationDocument,
  ) async {
    final reservationData = reservationDocument.data();
    final sessionId = reservationData['trainingSessionId'] as String? ?? '';

    final denormalizedTrainingName =
        reservationData['trainingName'] as String? ?? '';
    final denormalizedTrainerName =
        reservationData['trainerName'] as String? ?? '';
    final denormalizedStartTime =
        (reservationData['trainingStartTime'] as Timestamp?)?.toDate();
    final denormalizedEndTime =
        (reservationData['trainingEndTime'] as Timestamp?)?.toDate();

    if (sessionId.isNotEmpty &&
        denormalizedTrainingName.isNotEmpty &&
        denormalizedTrainerName.isNotEmpty &&
        denormalizedStartTime != null &&
        denormalizedEndTime != null) {
      if (denormalizedEndTime.isBefore(DateTime.now())) {
        return null;
      }

      return _ReservationDetail(
        reservationId: reservationDocument.id,
        trainingSessionId: sessionId,
        trainingName: denormalizedTrainingName,
        trainerName: denormalizedTrainerName,
        startTime: denormalizedStartTime,
        endTime: denormalizedEndTime,
      );
    }

    if (sessionId.isEmpty) {
      return null;
    }

    final firestore = FirebaseFirestore.instance;

    final sessionDocument = await firestore
        .collection('trainingSessions')
        .doc(sessionId)
        .get();

    final sessionData = sessionDocument.data();

    if (sessionData == null) {
      return null;
    }

    final trainingTypeId = sessionData['trainingTypeId'] as String? ?? '';
    final trainerId = sessionData['trainerId'] as String? ?? '';

    final trainingTypeDocument = await firestore
        .collection('trainingTypes')
        .doc(trainingTypeId)
        .get();

    final trainerDocument = await firestore
        .collection('users')
        .doc(trainerId)
        .get();

    final trainingTypeData = trainingTypeDocument.data();
    final trainerData = trainerDocument.data();
    final trainerPublicName = trainerData?['publicName'] as String? ?? '';
    final trainerFirstName = trainerData?['firstName'] as String? ?? '';
    final trainerDisplayName = trainerData?['displayName'] as String? ?? '';

    final trainerName = trainerPublicName.isNotEmpty
        ? trainerPublicName
        : trainerFirstName.isNotEmpty
        ? trainerFirstName
        : trainerDisplayName.isNotEmpty
        ? trainerDisplayName
        : AppTexts.unknownTrainer;

    final startTime =
        (sessionData['startTime'] as Timestamp?)?.toDate() ?? DateTime.now();

    final endTime =
        (sessionData['endTime'] as Timestamp?)?.toDate() ?? DateTime.now();

    if (endTime.isBefore(DateTime.now())) {
      return null;
    }

    return _ReservationDetail(
      reservationId: reservationDocument.id,
      trainingSessionId: sessionId,
      trainingName:
          trainingTypeData?['name'] as String? ?? AppTexts.unknownTraining,
      trainerName: trainerName,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<List<_ReservationDetail>> _loadReservationDetails(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> reservationDocuments,
  ) async {
    final loadedDetails = await Future.wait(
      reservationDocuments.map(_loadReservationDetail),
    );

    final details = loadedDetails.whereType<_ReservationDetail>().toList();

    details.sort((a, b) => a.startTime.compareTo(b.startTime));

    return details;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text(AppTexts.noReservations));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'active')
          .where('entryStatus', isEqualTo: 'reserved')
          .where(
            'trainingStartTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
          )
          .orderBy('trainingStartTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text(AppTexts.reservationsLoadError));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reservationDocuments = snapshot.data?.docs ?? [];

        if (reservationDocuments.isEmpty) {
          return const Center(child: Text(AppTexts.noReservations));
        }

        return FutureBuilder<List<_ReservationDetail>>(
          future: _loadReservationDetails(reservationDocuments),
          builder: (context, detailSnapshot) {
            if (detailSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (detailSnapshot.hasError) {
              return const Center(child: Text(AppTexts.reservationsLoadError));
            }

            final reservations = detailSnapshot.data ?? [];

            if (reservations.isEmpty) {
              return const Center(child: Text(AppTexts.noReservations));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: reservations.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.cardGap),
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                final canShowQrCode = _canShowQrCode(reservation, reservations);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                reservation.trainingName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              tooltip: AppTexts.cancelReservation,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmCancelReservation(
                                context,
                                reservation,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${_formatDateTime(reservation.startTime)} - '
                          '${_formatTime(reservation.endTime)}',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text('${AppTexts.trainer}: ${reservation.trainerName}'),
                        if (canShowQrCode) ...[
                          const SizedBox(height: AppSpacing.sectionGap),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () => _openReservationQrScreen(
                                context,
                                reservation,
                              ),
                              icon: const Icon(Icons.qr_code),
                              label: const Text(AppTexts.showQrCode),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _canShowQrCode(
    _ReservationDetail reservation,
    List<_ReservationDetail> reservations,
  ) {
    final now = DateTime.now();

    final todayReservations = reservations.where((item) {
      return _isSameDate(item.startTime, now) && item.endTime.isAfter(now);
    }).toList();

    todayReservations.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (todayReservations.isEmpty) {
      return false;
    }

    return todayReservations.first.reservationId == reservation.reservationId;
  }
}

class _ReservationDetail {
  const _ReservationDetail({
    required this.reservationId,
    required this.trainingSessionId,
    required this.trainingName,
    required this.trainerName,
    required this.startTime,
    required this.endTime,
  });

  final String reservationId;
  final String trainingSessionId;
  final String trainingName;
  final String trainerName;
  final DateTime startTime;
  final DateTime endTime;
}
