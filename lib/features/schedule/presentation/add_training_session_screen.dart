import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../data/schedule_service.dart';
import '../domain/training_type.dart';

/*  Obrazovka/formulár pre trénera alebo admina na pridanie konkrétneho termínu 
do rozvrhu výberom existujúceho typu cvičenia, dátumu, času, trvania a kapacity.*/
class AddTrainingSessionScreen extends StatefulWidget {
  const AddTrainingSessionScreen({super.key});

  @override
  State<AddTrainingSessionScreen> createState() =>
      _AddTrainingSessionScreenState();
}

class _AddTrainingSessionScreenState extends State<AddTrainingSessionScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  String? _selectedTrainingTypeId;
  String? _selectedTrainerId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  TrainingType? _findSelectedTrainingType(List<TrainingType> trainingTypes) {
    for (final trainingType in trainingTypes) {
      if (trainingType.id == _selectedTrainingTypeId) {
        return trainingType;
      }
    }

    return null;
  }

  Future<String?> _getCurrentUserRole(String userId) async {
    final userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return userDocument.data()?['role'] as String?;
  }

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
              .where((trainer) {
                return trainer.isActive;
              })
              .toList();

          trainers.sort((a, b) => a.name.compareTo(b.name));

          return trainers;
        });
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final latestAllowedDate = today.add(const Duration(days: 14));

    final initialDate = _selectedDate == null
        ? today
        : _selectedDate!.isAfter(latestAllowedDate)
        ? latestAllowedDate
        : _selectedDate!;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: latestAllowedDate,
      locale: const Locale('sk', 'SK'),
      helpText: AppTexts.selectDate,
      cancelText: AppTexts.cancel,
      confirmText: AppTexts.ok,
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
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

  String _formatDate(DateTime? date) {
    if (date == null) return AppTexts.date;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return AppTexts.startTime;

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _saveTrainingSession(List<TrainingType> trainingTypes) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final selectedTrainingType = _findSelectedTrainingType(trainingTypes);

    final currentUserRole = currentUser == null
        ? null
        : await _getCurrentUserRole(currentUser.uid);

    if (!mounted) return;

    final trainerId = currentUserRole == AppRoles.admin
        ? _selectedTrainerId
        : currentUser?.uid;

    final durationMinutes = int.tryParse(_durationController.text.trim());
    final capacity = int.tryParse(_capacityController.text.trim());

    if (currentUser == null ||
        selectedTrainingType == null ||
        trainerId == null ||
        _selectedDate == null ||
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

    final startTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (!startTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingSessionInPast)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _scheduleService.createTrainingSession(
        trainingType: selectedTrainingType,
        currentUser: currentUser,
        trainerId: trainerId,
        startTime: startTime,
        durationMinutes: durationMinutes,
        capacity: capacity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingSessionCreated)),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      String message = AppTexts.saveError;

      if (error.toString().contains('training-session-overlap')) {
        message = AppTexts.trainingSessionOverlap;
      } else if (error.toString().contains(
        'training-session-too-far-in-future',
      )) {
        message = AppTexts.trainingSessionTooFarInFuture;
      }

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

  String _resolveTrainerName(Map<String, dynamic> data) {
    final publicName = data['publicName'] as String? ?? '';
    final firstName = data['firstName'] as String? ?? '';
    final displayName = data['displayName'] as String? ?? '';

    if (publicName.trim().isNotEmpty) {
      return publicName.trim();
    }

    if (firstName.trim().isNotEmpty) {
      return firstName.trim();
    }

    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    return AppTexts.unknownTrainer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.addTrainingSession)),
      body: FutureBuilder<String?>(
        future: FirebaseAuth.instance.currentUser == null
            ? Future.value(null)
            : _getCurrentUserRole(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAdmin = roleSnapshot.data == AppRoles.admin;

          return StreamBuilder<List<TrainingType>>(
            stream: _scheduleService.watchTrainingTypes(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(AppTexts.trainingTypesLoadError),
                );
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
                  if (isAdmin) ...[
                    const SizedBox(height: 12),
                    _buildTrainerDropdown(),
                  ],
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
                    decoration: const InputDecoration(
                      labelText: AppTexts.capacity,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_formatDate(_selectedDate)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(_formatTime(_selectedTime)),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving
                        ? null
                        : () => _saveTrainingSession(trainingTypes),
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
