import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';
import 'schedule_service.dart';
import 'training_type.dart';
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
      _durationController.text =
          selectedTrainingType.defaultDurationMinutes.toString();
      _capacityController.text =
          selectedTrainingType.defaultCapacity.toString();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();

    final initialTime = _selectedTime ??
        TimeOfDay(
          hour: now.hour,
          minute: 0,
        );

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

    final durationMinutes = int.tryParse(_durationController.text.trim());
    final capacity = int.tryParse(_capacityController.text.trim());

    if (currentUser == null ||
        selectedTrainingType == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        durationMinutes == null ||
        capacity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.fillAllFields)),
      );
      return;
    }

    if (durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.invalidDuration)),
      );
      return;
    }

    if (capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.invalidCapacity)),
      );
      return;
    }

    final startTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await _scheduleService.createTrainingSession(
        trainingType: selectedTrainingType,
        currentUser: currentUser,
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

      final message = error.toString().contains('training-session-overlap')
          ? AppTexts.trainingSessionOverlap
          : AppTexts.saveError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.addTrainingSession),
      ),
      body: StreamBuilder<List<TrainingType>>(
        stream: _scheduleService.watchTrainingTypes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(AppTexts.trainingTypesLoadError),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final trainingTypes = snapshot.data ?? [];

          if (trainingTypes.isEmpty) {
            return const Center(
              child: Text(AppTexts.noTrainings),
            );
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
      ),
    );
  }
}