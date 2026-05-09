import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../data/schedule_service.dart';
import '../domain/training_type.dart';

/* Obrazovka/formulár pre admina na vytvorenie pravidelnej týždennej šablóny rozvrhu,
   podľa ktorej sa neskôr budú automaticky generovať konkrétne termíny tréningov. */
class AddScheduleTemplateScreen extends StatefulWidget {
  const AddScheduleTemplateScreen({super.key});

  @override
  State<AddScheduleTemplateScreen> createState() =>
      _AddScheduleTemplateScreenState();
}

class _AddScheduleTemplateScreenState extends State<AddScheduleTemplateScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  String? _selectedTrainingTypeId;
  String? _selectedTrainerId;
  int? _selectedWeekday;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Stream<List<_TrainerOption>> _watchTrainers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: AppRoles.trainer)
        .snapshots()
        .map((snapshot) {
          final trainers = snapshot.docs
              .map((document) {
                final data = document.data();

                return _TrainerOption(
                  id: document.id,
                  name: data['displayName'] as String? ?? 'Neznámy tréner',
                  isActive: data['isActive'] as bool? ?? true,
                );
              })
              .where((trainer) {
                return trainer.isActive;
              })
              .toList();

          trainers.sort((a, b) => a.name.compareTo(b.name));

          return trainers;
        });
  }

  TrainingType? _findSelectedTrainingType(List<TrainingType> trainingTypes) {
    for (final trainingType in trainingTypes) {
      if (trainingType.id == _selectedTrainingTypeId) {
        return trainingType;
      }
    }

    return null;
  }

  void _selectTrainingType(
    String? trainingTypeId,
    List<TrainingType> trainingTypes,
  ) {
    if (trainingTypeId == null) return;

    final selectedTrainingType = trainingTypes.firstWhere(
      (trainingType) => trainingType.id == trainingTypeId,
    );

    setState(() {
      _selectedTrainingTypeId = trainingTypeId;
      _durationController.text = selectedTrainingType.defaultDurationMinutes
          .toString();
      _capacityController.text = selectedTrainingType.defaultCapacity
          .toString();
    });
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();

    final initialTime = _selectedTime ?? TimeOfDay(hour: now.hour, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return AppTexts.startTime;

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _saveScheduleTemplate(List<TrainingType> trainingTypes) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final selectedTrainingType = _findSelectedTrainingType(trainingTypes);

    final durationMinutes = int.tryParse(_durationController.text.trim());
    final capacity = int.tryParse(_capacityController.text.trim());

    if (currentUser == null ||
        selectedTrainingType == null ||
        _selectedTrainerId == null ||
        _selectedWeekday == null ||
        _selectedTime == null ||
        durationMinutes == null ||
        capacity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.fillAllFields)));
      return;
    }

    if (durationMinutes <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.invalidDuration)));
      return;
    }

    if (capacity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.invalidCapacity)));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _scheduleService.createScheduleTemplate(
        trainingType: selectedTrainingType,
        currentUser: currentUser,
        trainerId: _selectedTrainerId!,
        weekday: _selectedWeekday!,
        startHour: _selectedTime!.hour,
        startMinute: _selectedTime!.minute,
        durationMinutes: durationMinutes,
        capacity: capacity,
        validFrom: DateTime.now(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.scheduleTemplateCreated)),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      final errorText = error.toString();

      final message = errorText.contains('schedule-template-already-exists')
          ? AppTexts.scheduleTemplateAlreadyExists
          : errorText.contains('schedule-template-overlap')
          ? AppTexts.scheduleTemplateOverlap
          : AppTexts.saveError;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTrainerDropdown() {
    return StreamBuilder<List<_TrainerOption>>(
      stream: _watchTrainers(),
      builder: (context, trainerSnapshot) {
        if (trainerSnapshot.hasError) {
          return const Text(AppTexts.trainersLoadError);
        }

        if (trainerSnapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }

        final trainers = trainerSnapshot.data ?? [];

        return DropdownButtonFormField<String>(
          initialValue: _selectedTrainerId,
          decoration: const InputDecoration(labelText: AppTexts.trainer),
          items: trainers.map((trainer) {
            return DropdownMenuItem<String>(
              value: trainer.id,
              child: Text(trainer.name),
            );
          }).toList(),
          onChanged: _isSaving
              ? null
              : (trainerId) {
                  setState(() {
                    _selectedTrainerId = trainerId;
                  });
                },
          hint: const Text(AppTexts.selectTrainer),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.addScheduleTemplate)),
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
            return const Center(child: Text(AppTexts.noTrainings));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedTrainingTypeId,
                decoration: const InputDecoration(
                  labelText: AppTexts.trainingType,
                ),
                items: trainingTypes.map((trainingType) {
                  return DropdownMenuItem<String>(
                    value: trainingType.id,
                    child: Text(trainingType.name),
                  );
                }).toList(),
                onChanged: _isSaving
                    ? null
                    : (trainingTypeId) {
                        _selectTrainingType(trainingTypeId, trainingTypes);
                      },
                hint: const Text(AppTexts.selectTrainingType),
              ),
              const SizedBox(height: 12),
              _buildTrainerDropdown(),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _selectedWeekday,
                decoration: const InputDecoration(labelText: AppTexts.weekday),
                items: List.generate(7, (index) {
                  final weekday = index + 1;

                  return DropdownMenuItem<int>(
                    value: weekday,
                    child: Text(AppTexts.weekdays[index]),
                  );
                }),
                onChanged: _isSaving
                    ? null
                    : (weekday) {
                        setState(() {
                          _selectedWeekday = weekday;
                        });
                      },
                hint: const Text(AppTexts.selectWeekday),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _pickTime,
                icon: const Icon(Icons.access_time),
                label: Text(_formatTime(_selectedTime)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _durationController,
                enabled: !_isSaving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppTexts.duration,
                  suffixText: AppTexts.minutes,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _capacityController,
                enabled: !_isSaving,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: AppTexts.capacity),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving
                    ? null
                    : () => _saveScheduleTemplate(trainingTypes),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppTexts.save),
              ),
            ],
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
