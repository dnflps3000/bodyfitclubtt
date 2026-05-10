import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../../../core/widgets/day_card_selector.dart';
import '../data/schedule_service.dart';
import '../domain/schedule_item.dart';
import '../../memberships/presentation/assign_membership_screen.dart';
import '../../reservations/data/reservation_service.dart';
import '../../reservations/presentation/attendance_screen.dart';
import 'add_training_session_screen.dart';
import 'schedule_management_screen.dart';

/* Zobrazuje obrazovku Rozvrh, teda zoznam tréningov, ich čas,
   trénera, voľné miesta, popis a tlačidlo rezervácie. */
class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  Stream<String?> _watchCurrentUserRole() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value(null);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          return data?['role'] as String?;
        });
  }

  Stream<Set<String>> _watchMyReservedSessionIds() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value({});
    }

    return FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((document) {
                final data = document.data();
                final status = data['status'] as String? ?? '';

                return status != 'cancelled';
              })
              .map((document) {
                final data = document.data();
                return data['trainingSessionId'] as String? ?? '';
              })
              .where((sessionId) {
                return sessionId.isNotEmpty;
              })
              .toSet();
        });
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<DateTime> _nextFourteenDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(14, (index) => today.add(Duration(days: index)));
  }

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

  Future<void> _openAddTrainingSessionScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTrainingSessionScreen()));
  }

  Future<void> _openScheduleManagementScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScheduleManagementScreen()));
  }

  Future<void> _openAssignMembershipScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AssignMembershipScreen()));
  }

  Future<void> _openTrainerAttendanceScreen(
    BuildContext context,
    String? role,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          trainerId: role == AppRoles.trainer ? currentUser.uid : null,
        ),
      ),
    );
  }

  Future<void> _confirmCancelTrainingSession(
    BuildContext context,
    ScheduleItem item,
    String? role,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.cancelTrainingSessionTitle),
          content: Text(
            '${AppTexts.cancelTrainingSessionQuestion}\n\n'
            '${item.trainingType.name}\n'
            '${_formatDateTime(item.session.startTime)} - '
            '${_formatTime(item.session.endTime)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppTexts.cancelTrainingSessionConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        return;
      }

      await ScheduleService().cancelTrainingSessionWithReservations(
        sessionId: item.session.id,
        currentUser: currentUser,
        role: role,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingSessionCancelled)),
      );
    } catch (error) {
      if (!context.mounted) return;

      final errorText = error.toString();

      final message = errorText.contains('trainer-not-owner-of-session')
          ? AppTexts.trainerCanCancelOnlyOwnSession
          : errorText.contains('trainer-cannot-cancel-started-session')
          ? AppTexts.trainerCannotCancelStartedSession
          : AppTexts.cancelTrainingSessionError;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _reserveTrainingSession(
    BuildContext context,
    ScheduleItem item,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      await ReservationService().reserveTrainingSession(
        session: item.session,
        currentUser: currentUser,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.reservationCreated)),
      );
    } catch (error) {
      if (!context.mounted) return;

      final errorText = error.toString();

      final message = errorText.contains('reservation-already-exists')
          ? AppTexts.reservationAlreadyExists
          : errorText.contains('training-session-full')
          ? AppTexts.reservationTrainingFull
          : errorText.contains('training-session-not-available')
          ? AppTexts.reservationTrainingNotAvailable
          : errorText.contains('training-session-already-started')
          ? AppTexts.reservationTrainingAlreadyStarted
          : errorText.contains('no-available-membership-entry')
          ? AppTexts.noAvailableEntries
          : AppTexts.reservationError;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildManagementButtons(BuildContext context, String? role) {
    final isAdmin = role == AppRoles.admin;
    final isTrainer = role == AppRoles.trainer;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!isAdmin && !isTrainer) {
      return const SizedBox.shrink();
    }

    final buttons = <Widget>[
      if (isAdmin)
        FilledButton.icon(
          onPressed: () => _openScheduleManagementScreen(context),
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: const Text(AppTexts.scheduleManagement),
        ),
      if (isAdmin || isTrainer)
        FilledButton.icon(
          onPressed: () => _openAddTrainingSessionScreen(context),
          icon: const Icon(Icons.event_available),
          label: const Text(AppTexts.addTrainingSession),
        ),
      if (isTrainer)
        FilledButton.icon(
          onPressed: () => _openAssignMembershipScreen(context),
          icon: const Icon(Icons.card_membership),
          label: const Text(AppTexts.assignMembership),
        ),
      if (isAdmin || isTrainer)
        FilledButton.icon(
          onPressed: () => _openTrainerAttendanceScreen(context, role),
          icon: const Icon(Icons.fact_check),
          label: const Text(AppTexts.attendance),
        ),
    ];

    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            for (var index = 0; index < buttons.length; index++) ...[
              Expanded(child: buttons[index]),
              if (index < buttons.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < buttons.length; index++) ...[
            buttons[index],
            if (index < buttons.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _nextFourteenDays();

    return DayCardSelector(
      key: const PageStorageKey('schedule-day-selector'),
      days: days,
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleService = ScheduleService();

    return StreamBuilder<String?>(
      stream: _watchCurrentUserRole(),
      builder: (context, roleSnapshot) {
        final role = roleSnapshot.data;

        return StreamBuilder<List<ScheduleItem>>(
          stream: scheduleService.watchScheduleItems(),
          builder: (context, scheduleSnapshot) {
            if (scheduleSnapshot.hasError) {
              return const Center(child: Text(AppTexts.trainingsLoadError));
            }

            if (scheduleSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = scheduleSnapshot.data ?? [];

            final filteredItems =
                items.where((item) {
                  return _isSameDate(item.session.startTime, _selectedDate);
                }).toList()..sort((a, b) {
                  return a.session.startTime.compareTo(b.session.startTime);
                });

            return Column(
              children: [
                _buildManagementButtons(context, role),
                _buildDaySelector(),
                Expanded(
                  child: _buildScheduleListFromItems(
                    context: context,
                    role: role,
                    items: filteredItems,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleListFromItems({
    required BuildContext context,
    required String? role,
    required List<ScheduleItem> items,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAdmin = role == AppRoles.admin;
    final isTrainer = role == AppRoles.trainer;
    final isManager = isAdmin || isTrainer;
    final canReserveTrainingSession =
        role == AppRoles.user || role == null || role.isEmpty;

    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            AppTexts.noTrainingsForSelectedDay,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return StreamBuilder<Set<String>>(
      stream: _watchMyReservedSessionIds(),
      builder: (context, reservationSnapshot) {
        final reservedSessionIds = reservationSnapshot.data ?? <String>{};

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final session = item.session;
            final trainingType = item.trainingType;
            final isReserved = reservedSessionIds.contains(session.id);
            final sessionHasNotStarted = session.startTime.isAfter(
              DateTime.now(),
            );
            final canCancelTrainingSession =
                isAdmin ||
                (isTrainer &&
                    session.trainerId == currentUser?.uid &&
                    sessionHasNotStarted);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            trainingType.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (canCancelTrainingSession)
                          IconButton(
                            tooltip: AppTexts.cancelTrainingSession,
                            icon: const Icon(Icons.event_busy_outlined),
                            onPressed: () => _confirmCancelTrainingSession(
                              context,
                              item,
                              role,
                            ),
                          )
                        else if (canReserveTrainingSession)
                          FilledButton(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              minimumSize: const Size(0, 40),
                            ),
                            onPressed: isReserved
                                ? null
                                : session.hasFreeSpots
                                ? () => _reserveTrainingSession(context, item)
                                : null,
                            child: Text(
                              isReserved
                                  ? AppTexts.reserved
                                  : session.hasFreeSpots
                                  ? AppTexts.reserve
                                  : AppTexts.fullCapacity,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatDateTime(session.startTime)} - '
                      '${_formatTime(session.endTime)}',
                    ),
                    const SizedBox(height: 8),
                    Text('${AppTexts.trainer}: ${item.trainerName}'),
                    const SizedBox(height: 8),
                    Text(
                      '${AppTexts.freeSpots}: '
                      '${session.freeSpots}/${session.capacity}',
                    ),
                    if (!isManager && trainingType.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(trainingType.description),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
