import 'package:flutter/material.dart';
import 'add_training_attendance_screen.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../data/training_history_service.dart';

class TrainingHistoryDetailScreen extends StatefulWidget {
  const TrainingHistoryDetailScreen({super.key, required this.session});

  final TrainingHistorySession session;

  @override
  State<TrainingHistoryDetailScreen> createState() =>
      _TrainingHistoryDetailScreenState();
}

class _TrainingHistoryDetailScreenState
    extends State<TrainingHistoryDetailScreen> {
  final TrainingHistoryService _service = TrainingHistoryService();
  String? _runningActionReservationId;

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _reservationStatusLabel(TrainingHistoryReservation reservation) {
    if (reservation.isAttended) {
      return AppTexts.attendedStatus;
    }

    if (reservation.isNoShow) {
      return AppTexts.noShowStatus;
    }

    if (reservation.isCancelled) {
      return AppTexts.cancelled;
    }

    if (reservation.isReserved) {
      return AppTexts.reservedStatus;
    }

    return reservation.status;
  }

  Future<bool> _confirmAction(String message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppTexts.trainingHistoryDetail),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppTexts.confirm),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _runReservationAction({
    required TrainingHistoryReservation reservation,
    required String confirmMessage,
    required Future<void> Function() action,
    String? successMessage,
    String? errorMessage,
  }) async {
    final resolvedSuccessMessage =
        successMessage ?? AppTexts.attendanceActionDone;
    final resolvedErrorMessage = errorMessage ?? AppTexts.attendanceActionError;

    final confirmed = await _confirmAction(confirmMessage);

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _runningActionReservationId = reservation.id;
    });

    try {
      await action();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolvedSuccessMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resolvedErrorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _runningActionReservationId = null;
        });
      }
    }
  }

  Future<void> _markAsAttended(TrainingHistoryReservation reservation) async {
    await _runReservationAction(
      reservation: reservation,
      confirmMessage: AppTexts.markAsAttendedQuestion,
      action: () {
        return _service.markReservationAttendanceFromHistory(
          reservationId: reservation.id,
          trainingSessionId: widget.session.id,
          attended: true,
        );
      },
    );
  }

  Future<void> _markAsNoShow(TrainingHistoryReservation reservation) async {
    await _runReservationAction(
      reservation: reservation,
      confirmMessage: AppTexts.markAsNoShowQuestion,
      action: () {
        return _service.markReservationAttendanceFromHistory(
          reservationId: reservation.id,
          trainingSessionId: widget.session.id,
          attended: false,
        );
      },
    );
  }

  Future<void> _cancelReservation(
    TrainingHistoryReservation reservation,
  ) async {
    await _runReservationAction(
      reservation: reservation,
      confirmMessage: AppTexts.cancelReservationQuestion,
      successMessage: AppTexts.reservationCancelled,
      errorMessage: AppTexts.reservationCancelError,
      action: () {
        return _service.cancelReservationFromHistory(
          reservationId: reservation.id,
          trainingSessionId: widget.session.id,
        );
      },
    );
  }

  Future<void> _revertAttendance(TrainingHistoryReservation reservation) async {
    await _runReservationAction(
      reservation: reservation,
      confirmMessage: reservation.isNoShow
          ? AppTexts.revertNoShowQuestion
          : AppTexts.revertAttendanceQuestion,
      action: () {
        return _service.revertReservationAttendanceFromHistory(
          reservationId: reservation.id,
          trainingSessionId: widget.session.id,
        );
      },
    );
  }

  Future<void> _openAddAttendanceScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTrainingAttendanceScreen(session: widget.session),
      ),
    );
  }

  int _countAttended(List<TrainingHistoryReservation> reservations) {
    return reservations.where((reservation) => reservation.isAttended).length;
  }

  int _countNoShow(List<TrainingHistoryReservation> reservations) {
    return reservations.where((reservation) => reservation.isNoShow).length;
  }

  int _countReserved(List<TrainingHistoryReservation> reservations) {
    return reservations.where((reservation) => reservation.isReserved).length;
  }

  int _countCancelled(List<TrainingHistoryReservation> reservations) {
    return reservations.where((reservation) => reservation.isCancelled).length;
  }

  Widget _buildSessionSummary(List<TrainingHistoryReservation> reservations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.session.trainingName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_formatDateTime(widget.session.startTime)} – ${_formatTime(widget.session.endTime)}',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('${AppTexts.trainer}: ${widget.session.trainerName}'),
            const SizedBox(height: AppSpacing.cardGap),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                Chip(
                  label: Text(
                    '${AppTexts.capacityLabel} ${widget.session.reservedCount}/${widget.session.capacity}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${AppTexts.attendedCountLabel} ${_countAttended(reservations)}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${AppTexts.noShowCountLabel} ${_countNoShow(reservations)}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${AppTexts.reservedCountLabel} ${_countReserved(reservations)}',
                  ),
                ),
                Chip(
                  label: Text(
                    '${AppTexts.cancelledCountLabel} ${_countCancelled(reservations)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(TrainingHistoryReservation reservation) {
    final statusLabel = _reservationStatusLabel(reservation);
    final isRunning = _runningActionReservationId == reservation.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(reservation.userName),
              subtitle: Text(
                [
                  if (reservation.userEmail.isNotEmpty) reservation.userEmail,
                  if (reservation.membershipPlanName.isNotEmpty)
                    '${AppTexts.membershipPrefix}: ${reservation.membershipPlanName}',
                  '${AppTexts.statusPrefix}: $statusLabel',
                  if (reservation.attendanceMarkedAt != null)
                    '${AppTexts.markedAtPrefix}: ${_formatDateTime(reservation.attendanceMarkedAt!)}',
                ].join('\n'),
              ),
              isThreeLine: true,
            ),
            if (isRunning)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardGap,
                ),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (reservation.isReserved) ...[
                      OutlinedButton.icon(
                        onPressed: () => _markAsAttended(reservation),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(AppTexts.markAsAttended),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _markAsNoShow(reservation),
                        icon: const Icon(Icons.highlight_off),
                        label: Text(AppTexts.markAsNoShow),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _cancelReservation(reservation),
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(AppTexts.cancelReservation),
                      ),
                    ],
                    if (reservation.isAttended || reservation.isNoShow)
                      OutlinedButton.icon(
                        onPressed: () => _revertAttendance(reservation),
                        icon: const Icon(Icons.undo),
                        label: Text(
                          reservation.isNoShow
                              ? AppTexts.revertNoShow
                              : AppTexts.revertAttendance,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.trainingHistoryDetail),
        actions: [
          IconButton(
            tooltip: AppTexts.addTrainingAttendance,
            onPressed: _openAddAttendanceScreen,
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: StreamBuilder<List<TrainingHistoryReservation>>(
        stream: _service.watchTrainingReservations(
          trainingSessionId: widget.session.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(AppTexts.trainingHistoryReservationsLoadError),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _buildSessionSummary(reservations),
              const SizedBox(height: AppSpacing.cardGap),
              if (reservations.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    child: Text(AppTexts.noReservationsForTrainingHistory),
                  ),
                )
              else
                ...reservations.map(_buildReservationCard),
            ],
          );
        },
      ),
    );
  }
}
