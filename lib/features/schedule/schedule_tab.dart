import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_roles.dart';
import '../../core/theme/app_texts.dart';
import 'add_training_session_screen.dart';
import 'add_training_type_screen.dart';
import 'schedule_item.dart';
import 'schedule_service.dart';
import 'add_schedule_template_screen.dart';

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

  bool _canAddTrainingType(String? role) {
    return role == AppRoles.admin;
  }

  bool _canManageTrainingSessions(String? role) {
    return role == AppRoles.admin || role == AppRoles.trainer;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<DateTime> _nextSevenDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(
      14,
      (index) => today.add(Duration(days: index)),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$day.$month.';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _dayLabel(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (_isSameDate(dateTime, today)) {
      return AppTexts.today;
    }

    if (_isSameDate(dateTime, tomorrow)) {
      return AppTexts.tomorrow;
    }

    final weekdayLabel = AppTexts.shortWeekdays[dateTime.weekday - 1];
    return '$weekdayLabel ${_formatDate(dateTime)}';
  }

  Future<void> _openAddTrainingTypeScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTrainingTypeScreen(),
      ),
    );
  }

  Future<void> _openAddScheduleTemplateScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddScheduleTemplateScreen(),
      ),
    );
  }

  Future<void> _openAddTrainingSessionScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTrainingSessionScreen(),
      ),
    );
  }

  Future<void> _confirmDeleteTrainingSession(
    BuildContext context,
    ScheduleItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.deleteTrainingSessionTitle),
          content: Text(
            '${AppTexts.deleteTrainingSessionQuestion}\n\n'
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
              child: const Text(AppTexts.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ScheduleService().deleteTrainingSession(item.session.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingSessionDeleted)),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.deleteError)),
      );
    }
  }

  Widget _buildManagementButtons(BuildContext context, String? role) {
    final canAddTrainingType = _canAddTrainingType(role);
    final canManageTrainingSessions = _canManageTrainingSessions(role);

    if (!canAddTrainingType && !canManageTrainingSessions) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canAddTrainingType)
            FilledButton.icon(
              onPressed: () => _openAddTrainingTypeScreen(context),
              icon: const Icon(Icons.add),
              label: const Text(AppTexts.addTrainingType),
            ),
          if (canAddTrainingType) const SizedBox(height: 8),
          if (canAddTrainingType)
            FilledButton.icon(
              onPressed: () => _openAddScheduleTemplateScreen(context),
              icon: const Icon(Icons.calendar_view_week),
              label: const Text(AppTexts.addScheduleTemplate),
            ),
          if (canAddTrainingType && canManageTrainingSessions)
            const SizedBox(height: 8),
          if (canManageTrainingSessions)
            FilledButton.icon(
              onPressed: () => _openAddTrainingSessionScreen(context),
              icon: const Icon(Icons.event_available),
              label: const Text(AppTexts.addTrainingSession),
            ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _nextSevenDays();

    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDate(day, _selectedDate);

          return ChoiceChip(
            label: Text(_dayLabel(day)),
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedDate = day;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(String? role) {
    final scheduleService = ScheduleService();
    final canManageTrainingSessions = _canManageTrainingSessions(role);

    return StreamBuilder<List<ScheduleItem>>(
      stream: scheduleService.watchScheduleItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(AppTexts.trainingsLoadError),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data ?? [];
        final filteredItems = items.where((item) {
          return _isSameDate(item.session.startTime, _selectedDate);
        }).toList();

        if (filteredItems.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppTexts.noTrainingsForSelectedDay),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final session = item.session;
            final trainingType = item.trainingType;

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
                        if (canManageTrainingSessions)
                          IconButton(
                            tooltip: AppTexts.deleteTrainingSession,
                            onPressed: () =>
                                _confirmDeleteTrainingSession(context, item),
                            icon: const Icon(Icons.delete_outline),
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
                    if (trainingType.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(trainingType.description),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: session.hasFreeSpots ? () {} : null,
                        child: Text(
                          session.hasFreeSpots
                              ? AppTexts.reserve
                              : AppTexts.fullCapacity,
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _watchCurrentUserRole(),
      builder: (context, roleSnapshot) {
        final role = roleSnapshot.data;

        return Column(
          children: [
            _buildManagementButtons(context, role),
            _buildDaySelector(),
            Expanded(
              child: _buildScheduleList(role),
            ),
          ],
        );
      },
    );
  }
}
