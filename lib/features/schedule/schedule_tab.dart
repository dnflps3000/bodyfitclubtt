import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_roles.dart';
import '../../core/theme/app_texts.dart';
import 'add_training_session_screen.dart';
import 'add_training_type_screen.dart';
import 'schedule_item.dart';
import 'schedule_service.dart';

/* Zobrazuje obrazovku Rozvrh, teda zoznam tréningov, ich čas,
   trénera, voľné miesta, popis a tlačidlo rezervácie. */
class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

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

  Future<void> _openAddTrainingTypeScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTrainingTypeScreen(),
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

        if (items.isEmpty) {
          return const Center(
            child: Text(AppTexts.noTrainings),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
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
            Expanded(
              child: _buildScheduleList(role),
            ),
          ],
        );
      },
    );
  }
}