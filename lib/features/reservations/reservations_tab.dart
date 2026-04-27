import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';
import 'reservation_service.dart';

/* Zobrazuje rezervácie aktuálne prihláseného používateľa.
   Načíta jeho aktívne rezervácie z kolekcie reservations a ku každej dohľadá
   príslušný tréningový termín, typ cvičenia a meno trénera. */
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

  Future<_ReservationDetail?> _loadReservationDetail(
    QueryDocumentSnapshot<Map<String, dynamic>> reservationDocument,
  ) async {
    final reservationData = reservationDocument.data();
    final sessionId = reservationData['trainingSessionId'] as String? ?? '';

    if (sessionId.isEmpty) {
      return null;
    }

    final firestore = FirebaseFirestore.instance;

    final sessionDocument =
        await firestore.collection('trainingSessions').doc(sessionId).get();

    final sessionData = sessionDocument.data();

    if (sessionData == null) {
      return null;
    }

    final trainingTypeId = sessionData['trainingTypeId'] as String? ?? '';
    final trainerId = sessionData['trainerId'] as String? ?? '';

    final trainingTypeDocument =
        await firestore.collection('trainingTypes').doc(trainingTypeId).get();

    final trainerDocument =
        await firestore.collection('users').doc(trainerId).get();

    final trainingTypeData = trainingTypeDocument.data();
    final trainerData = trainerDocument.data();

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
      trainingName: trainingTypeData?['name'] as String? ?? 'Tréning',
      trainerName: trainerData?['displayName'] as String? ?? 'Neznámy tréner',
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<List<_ReservationDetail>> _loadReservationDetails(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> reservationDocuments,
  ) async {
    final details = <_ReservationDetail>[];

    for (final reservationDocument in reservationDocuments) {
      final detail = await _loadReservationDetail(reservationDocument);

      if (detail != null) {
        details.add(detail);
      }
    }

    details.sort((a, b) => a.startTime.compareTo(b.startTime));

    return details;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text(AppTexts.noReservations),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(AppTexts.reservationError),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reservationDocuments = snapshot.data?.docs ?? [];

        if (reservationDocuments.isEmpty) {
          return const Center(
            child: Text(AppTexts.noReservations),
          );
        }

        return FutureBuilder<List<_ReservationDetail>>(
          future: _loadReservationDetails(reservationDocuments),
          builder: (context, detailSnapshot) {
            if (detailSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (detailSnapshot.hasError) {
              return const Center(
                child: Text(AppTexts.reservationError),
              );
            }

            final reservations = detailSnapshot.data ?? [];

            if (reservations.isEmpty) {
              return const Center(
                child: Text(AppTexts.noReservations),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reservations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reservation = reservations[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.trainingName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatDateTime(reservation.startTime)} - '
                          '${_formatTime(reservation.endTime)}',
                        ),
                        const SizedBox(height: 8),
                        Text('${AppTexts.trainer}: ${reservation.trainerName}'),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () => _confirmCancelReservation(
                              context,
                              reservation,
                            ),
                            child: const Text(AppTexts.cancelReservation),
                          ),
                        ),
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