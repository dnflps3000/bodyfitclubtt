import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../data/schedule_service.dart';
import '../domain/schedule_template.dart';
import '../domain/training_type.dart';

class ScheduleTemplatesManagementScreen extends StatefulWidget {
  const ScheduleTemplatesManagementScreen({super.key});

  @override
  State<ScheduleTemplatesManagementScreen> createState() =>
      _ScheduleTemplatesManagementScreenState();
}

class _ScheduleTemplatesManagementScreenState
    extends State<ScheduleTemplatesManagementScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  Stream<List<_TrainerOption>> _watchTrainers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', whereIn: [AppRoles.trainer, AppRoles.admin])
        .orderBy('publicName')
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final trainers = snapshot.docs
              .map((document) {
                final data = document.data();

                return _TrainerOption(
                  id: document.id,
                  name: _resolveTrainerName(data),
                  isActive: data['isActive'] as bool? ?? true,
                );
              })
              .where((trainer) => trainer.isActive)
              .toList();

          trainers.sort((a, b) => a.name.compareTo(b.name));
          return trainers;
        });
  }

  String _resolveTrainerName(Map<String, dynamic> data) {
    final publicName = data['publicName'] as String? ?? '';
    final firstName = data['firstName'] as String? ?? '';
    final displayName = data['displayName'] as String? ?? '';

    if (publicName.trim().isNotEmpty) return publicName.trim();
    if (firstName.trim().isNotEmpty) return firstName.trim();
    if (displayName.trim().isNotEmpty) return displayName.trim();

    return AppTexts.unknownTrainer;
  }

  TrainingType? _findTrainingType(
    List<TrainingType> trainingTypes,
    String trainingTypeId,
  ) {
    for (final trainingType in trainingTypes) {
      if (trainingType.id == trainingTypeId) {
        return trainingType;
      }
    }

    return null;
  }

  String _trainerNameById(List<_TrainerOption> trainers, String trainerId) {
    for (final trainer in trainers) {
      if (trainer.id == trainerId) {
        return trainer.name;
      }
    }

    return AppTexts.unknownTrainer;
  }

  String _formatTemplateTime(ScheduleTemplate template) {
    final hour = template.startHour.toString().padLeft(2, '0');
    final minute = template.startMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showTemplateForm({
    ScheduleTemplate? template,
    required List<TrainingType> trainingTypes,
    required List<_TrainerOption> trainers,
  }) async {
    var selectedTrainingTypeId = template?.trainingTypeId;
    var selectedTrainerId = template?.trainerId;
    var selectedWeekday = template?.weekday;
    var selectedTime = template == null
        ? null
        : TimeOfDay(hour: template.startHour, minute: template.startMinute);
    var durationText = template?.durationMinutes.toString() ?? '';
    var capacityText = template?.capacity.toString() ?? '';
    var isDialogSaving = false;

    final isEdit = template != null;

    final successMessage = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> pickTime() async {
              final now = TimeOfDay.now();
              final pickedTime = await showTimePicker(
                context: dialogContext,
                initialTime:
                    selectedTime ?? TimeOfDay(hour: now.hour, minute: 0),
              );

              if (pickedTime == null) return;

              setDialogState(() {
                selectedTime = pickedTime;
              });
            }

            void selectTrainingType(String? trainingTypeId) {
              if (trainingTypeId == null) return;

              final trainingType = _findTrainingType(
                trainingTypes,
                trainingTypeId,
              );

              setDialogState(() {
                selectedTrainingTypeId = trainingTypeId;

                if (!isEdit && trainingType != null) {
                  durationText = trainingType.defaultDurationMinutes.toString();
                  capacityText = trainingType.defaultCapacity.toString();
                }
              });
            }

            Future<void> save() async {
              final currentUser = FirebaseAuth.instance.currentUser;
              final selectedTrainingType = selectedTrainingTypeId == null
                  ? null
                  : _findTrainingType(trainingTypes, selectedTrainingTypeId!);
              final durationMinutes = int.tryParse(durationText.trim());
              final capacity = int.tryParse(capacityText.trim());

              if (currentUser == null ||
                  selectedTrainingType == null ||
                  selectedTrainerId == null ||
                  selectedWeekday == null ||
                  selectedTime == null ||
                  durationMinutes == null ||
                  capacity == null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(AppTexts.fillAllFields)));
                return;
              }

              if (durationMinutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppTexts.invalidDuration)),
                );
                return;
              }

              if (capacity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppTexts.invalidCapacity)),
                );
                return;
              }

              setDialogState(() {
                isDialogSaving = true;
              });

              try {
                if (isEdit) {
                  await _scheduleService.updateScheduleTemplate(
                    scheduleTemplate: template,
                    trainingType: selectedTrainingType,
                    currentUser: currentUser,
                    trainerId: selectedTrainerId!,
                    weekday: selectedWeekday!,
                    startHour: selectedTime!.hour,
                    startMinute: selectedTime!.minute,
                    durationMinutes: durationMinutes,
                    capacity: capacity,
                  );
                } else {
                  await _scheduleService.createScheduleTemplate(
                    trainingType: selectedTrainingType,
                    currentUser: currentUser,
                    trainerId: selectedTrainerId!,
                    weekday: selectedWeekday!,
                    startHour: selectedTime!.hour,
                    startMinute: selectedTime!.minute,
                    durationMinutes: durationMinutes,
                    capacity: capacity,
                    validFrom: DateTime.now(),
                  );
                }

                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop(
                  isEdit
                      ? AppTexts.scheduleTemplateUpdated
                      : AppTexts.scheduleTemplateCreated,
                );
              } catch (error) {
                if (!mounted || !dialogContext.mounted) return;

                final errorText = error.toString();

                final message =
                    errorText.contains('schedule-template-already-exists')
                    ? AppTexts.scheduleTemplateAlreadyExists
                    : errorText.contains('schedule-template-overlap')
                    ? AppTexts.scheduleTemplateOverlap
                    : AppTexts.saveError;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));

                setDialogState(() {
                  isDialogSaving = false;
                });
              }
            }

            final formattedTime = selectedTime == null
                ? AppTexts.startTime
                : '${selectedTime!.hour.toString().padLeft(2, '0')}:'
                      '${selectedTime!.minute.toString().padLeft(2, '0')}';

            return AlertDialog(
              title: Text(
                isEdit
                    ? AppTexts.editScheduleTemplate
                    : AppTexts.addScheduleTemplate,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedTrainingTypeId,
                      decoration: InputDecoration(
                        labelText: AppTexts.trainingType,
                      ),
                      items: trainingTypes.map((trainingType) {
                        return DropdownMenuItem<String>(
                          value: trainingType.id,
                          child: Text(trainingType.name),
                        );
                      }).toList(),
                      onChanged: isDialogSaving ? null : selectTrainingType,
                      hint: Text(AppTexts.selectTrainingType),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTrainerId,
                      decoration: InputDecoration(labelText: AppTexts.trainer),
                      items: trainers.map((trainer) {
                        return DropdownMenuItem<String>(
                          value: trainer.id,
                          child: Text(trainer.name),
                        );
                      }).toList(),
                      onChanged: isDialogSaving
                          ? null
                          : (trainerId) {
                              setDialogState(() {
                                selectedTrainerId = trainerId;
                              });
                            },
                      hint: Text(AppTexts.selectTrainer),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    DropdownButtonFormField<int>(
                      initialValue: selectedWeekday,
                      decoration: InputDecoration(labelText: AppTexts.weekday),
                      items: List.generate(7, (index) {
                        final weekday = index + 1;

                        return DropdownMenuItem<int>(
                          value: weekday,
                          child: Text(AppTexts.weekdays[index]),
                        );
                      }),
                      onChanged: isDialogSaving
                          ? null
                          : (weekday) {
                              setDialogState(() {
                                selectedWeekday = weekday;
                              });
                            },
                      hint: Text(AppTexts.selectWeekday),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    OutlinedButton.icon(
                      onPressed: isDialogSaving ? null : pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(formattedTime),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    TextFormField(
                      initialValue: durationText,
                      enabled: !isDialogSaving,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppTexts.duration,
                        suffixText: AppTexts.minutes,
                      ),
                      onChanged: (value) {
                        durationText = value;
                      },
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    TextFormField(
                      initialValue: capacityText,
                      enabled: !isDialogSaving,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: AppTexts.capacity),
                      onChanged: (value) {
                        capacityText = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDialogSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(AppTexts.cancel),
                ),
                FilledButton(
                  onPressed: isDialogSaving ? null : save,
                  child: isDialogSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppTexts.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || successMessage == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  }

  Future<void> _confirmDeactivateTemplate(ScheduleTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppTexts.deleteScheduleTemplate),
          content: Text(AppTexts.scheduleTemplateDeleteQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(AppTexts.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    try {
      await _scheduleService.deactivateScheduleTemplate(
        scheduleTemplate: template,
        currentUser: currentUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppTexts.scheduleTemplateDeleted)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppTexts.saveError)));
    }
  }

  Widget _buildTemplateCard({
    required ScheduleTemplate template,
    required List<TrainingType> trainingTypes,
    required List<_TrainerOption> trainers,
  }) {
    final trainingType = _findTrainingType(
      trainingTypes,
      template.trainingTypeId,
    );
    final trainingTypeName = trainingType?.name ?? AppTexts.unknownTraining;
    final trainerName = _trainerNameById(trainers, template.trainerId);
    final weekdayName = AppTexts.weekdays[template.weekday - 1];

    return Card(
      child: ListTile(
        title: Text('$weekdayName ${_formatTemplateTime(template)}'),
        subtitle: Text(
          '$trainingTypeName\n'
          '${AppTexts.trainer}: $trainerName\n'
          '${AppTexts.duration}: ${template.durationMinutes} ${AppTexts.minutes}, '
          '${AppTexts.capacity}: ${template.capacity}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: AppTexts.editScheduleTemplate,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showTemplateForm(
                template: template,
                trainingTypes: trainingTypes,
                trainers: trainers,
              ),
            ),
            IconButton(
              tooltip: AppTexts.deleteScheduleTemplate,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDeactivateTemplate(template),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.scheduleTemplatesManagement)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final trainingTypes = await _scheduleService
              .watchTrainingTypes()
              .first;
          final trainers = await _watchTrainers().first;

          if (!mounted) return;

          await _showTemplateForm(
            trainingTypes: trainingTypes,
            trainers: trainers,
          );
        },
        icon: const Icon(Icons.add),
        label: Text(AppTexts.addScheduleTemplate),
      ),
      body: StreamBuilder<List<TrainingType>>(
        stream: _scheduleService.watchTrainingTypes(),
        builder: (context, trainingTypesSnapshot) {
          if (trainingTypesSnapshot.hasError) {
            return Center(child: Text(AppTexts.trainingTypesLoadError));
          }

          if (trainingTypesSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trainingTypes = trainingTypesSnapshot.data ?? [];

          return StreamBuilder<List<_TrainerOption>>(
            stream: _watchTrainers(),
            builder: (context, trainersSnapshot) {
              if (trainersSnapshot.hasError) {
                return Center(child: Text(AppTexts.trainersLoadError));
              }

              if (trainersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final trainers = trainersSnapshot.data ?? [];

              return StreamBuilder<List<ScheduleTemplate>>(
                stream: _scheduleService.watchScheduleTemplates(),
                builder: (context, templatesSnapshot) {
                  if (templatesSnapshot.hasError) {
                    return Center(child: Text(AppTexts.trainingsLoadError));
                  }

                  if (templatesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final templates = templatesSnapshot.data ?? [];

                  if (templates.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          AppTexts.noScheduleTemplates,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.screenPadding,
                      AppSpacing.screenPadding,
                      AppSpacing.floatingActionButtonListBottomPadding,
                    ),
                    itemCount: templates.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(
                        template: templates[index],
                        trainingTypes: trainingTypes,
                        trainers: trainers,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TrainerOption {
  const _TrainerOption({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final String id;
  final String name;
  final bool isActive;
}
