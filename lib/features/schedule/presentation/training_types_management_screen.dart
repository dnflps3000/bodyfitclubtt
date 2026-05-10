import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../data/schedule_service.dart';
import '../domain/training_type.dart';

class TrainingTypesManagementScreen extends StatefulWidget {
  const TrainingTypesManagementScreen({super.key});

  @override
  State<TrainingTypesManagementScreen> createState() =>
      _TrainingTypesManagementScreenState();
}

class _TrainingTypesManagementScreenState
    extends State<TrainingTypesManagementScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  Future<void> _showTrainingTypeForm({TrainingType? trainingType}) async {
    var name = trainingType?.name ?? '';
    var description = trainingType?.description ?? '';
    var durationText = trainingType?.defaultDurationMinutes.toString() ?? '';
    var capacityText = trainingType?.defaultCapacity.toString() ?? '';
    var isDialogSaving = false;

    final isEdit = trainingType != null;

    final successMessage = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> save() async {
              final currentUser = FirebaseAuth.instance.currentUser;
              final trimmedName = name.trim();
              final trimmedDescription = description.trim();
              final defaultDurationMinutes = int.tryParse(durationText.trim());
              final defaultCapacity = int.tryParse(capacityText.trim());

              if (currentUser == null ||
                  trimmedName.isEmpty ||
                  trimmedDescription.isEmpty ||
                  defaultDurationMinutes == null ||
                  defaultCapacity == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppTexts.fillAllFields)),
                );
                return;
              }

              if (defaultDurationMinutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppTexts.invalidDuration)),
                );
                return;
              }

              if (defaultCapacity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppTexts.invalidCapacity)),
                );
                return;
              }

              setDialogState(() {
                isDialogSaving = true;
              });

              try {
                if (isEdit) {
                  await _scheduleService.updateTrainingType(
                    trainingType: trainingType,
                    name: trimmedName,
                    description: trimmedDescription,
                    defaultDurationMinutes: defaultDurationMinutes,
                    defaultCapacity: defaultCapacity,
                    currentUser: currentUser,
                  );
                } else {
                  await _scheduleService.createTrainingType(
                    name: trimmedName,
                    description: trimmedDescription,
                    defaultDurationMinutes: defaultDurationMinutes,
                    defaultCapacity: defaultCapacity,
                    currentUser: currentUser,
                  );
                }

                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop(
                  isEdit
                      ? AppTexts.trainingTypeUpdated
                      : AppTexts.trainingTypeCreated,
                );
              } catch (error) {
                if (!mounted || !dialogContext.mounted) return;

                final errorText = error.toString();

                final message =
                    errorText.contains('training-type-already-exists')
                    ? AppTexts.trainingTypeAlreadyExists
                    : AppTexts.saveError;

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));

                setDialogState(() {
                  isDialogSaving = false;
                });
              }
            }

            return AlertDialog(
              title: Text(
                isEdit ? AppTexts.editTrainingType : AppTexts.addTrainingType,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: name,
                      enabled: !isDialogSaving,
                      decoration: const InputDecoration(
                        labelText: AppTexts.trainingName,
                      ),
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: description,
                      enabled: !isDialogSaving,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: AppTexts.description,
                      ),
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: durationText,
                      enabled: !isDialogSaving,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppTexts.defaultDuration,
                        suffixText: AppTexts.minutes,
                      ),
                      onChanged: (value) {
                        durationText = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: capacityText,
                      enabled: !isDialogSaving,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppTexts.defaultCapacity,
                      ),
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
                  child: const Text(AppTexts.cancel),
                ),
                FilledButton(
                  onPressed: isDialogSaving ? null : save,
                  child: isDialogSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppTexts.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || successMessage == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));
  }

  Future<void> _confirmDeactivateTrainingType(TrainingType trainingType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.deleteTrainingType),
          content: Text(
            '${AppTexts.trainingTypeDeleteQuestion}\n\n'
            '${trainingType.name}',
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

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      await _scheduleService.deactivateTrainingType(
        trainingType: trainingType,
        currentUser: currentUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingTypeDeleted)),
      );
    } catch (error) {
      if (!mounted) return;

      final errorText = error.toString();

      final message = errorText.contains('training-type-used-by-template')
          ? AppTexts.trainingTypeUsedByTemplate
          : errorText.contains('training-type-used-by-session')
          ? AppTexts.trainingTypeUsedBySession
          : AppTexts.saveError;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildTrainingTypeCard(TrainingType trainingType) {
    return Card(
      child: ListTile(
        title: Text(trainingType.name),
        subtitle: Text(
          '${trainingType.description}\n'
          '${AppTexts.defaultDuration}: '
          '${trainingType.defaultDurationMinutes} ${AppTexts.minutes}\n'
          '${AppTexts.defaultCapacity}: ${trainingType.defaultCapacity}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: AppTexts.editTrainingType,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  _showTrainingTypeForm(trainingType: trainingType),
            ),
            IconButton(
              tooltip: AppTexts.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDeactivateTrainingType(trainingType),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.trainingTypesManagement)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTrainingTypeForm(),
        icon: const Icon(Icons.add),
        label: const Text(AppTexts.addTrainingType),
      ),
      body: StreamBuilder<List<TrainingType>>(
        stream: _scheduleService.watchTrainingTypes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppTexts.trainingTypesLoadError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trainingTypes = snapshot.data ?? [];

          if (trainingTypes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  AppTexts.noTrainingTypes,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            itemCount: trainingTypes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildTrainingTypeCard(trainingTypes[index]);
            },
          );
        },
      ),
    );
  }
}
