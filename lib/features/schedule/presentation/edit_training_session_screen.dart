import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../data/schedule_service.dart';
import '../domain/schedule_item.dart';

class EditTrainingSessionScreen extends StatefulWidget {
  const EditTrainingSessionScreen({
    super.key,
    required this.item,
    required this.role,
  });

  final ScheduleItem item;
  final String? role;

  @override
  State<EditTrainingSessionScreen> createState() =>
      _EditTrainingSessionScreenState();
}

class _EditTrainingSessionScreenState extends State<EditTrainingSessionScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  String? _selectedTrainerId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  bool get _isAdmin => widget.role == AppRoles.admin;

  @override
  void initState() {
    super.initState();

    final session = widget.item.session;
    final durationMinutes = session.endTime
        .difference(session.startTime)
        .inMinutes;

    _selectedTrainerId = session.trainerId;
    _selectedDate = DateTime(
      session.startTime.year,
      session.startTime.month,
      session.startTime.day,
    );
    _selectedTime = TimeOfDay(
      hour: session.startTime.hour,
      minute: session.startTime.minute,
    );
    _durationController.text = durationMinutes.toString();
    _capacityController.text = session.capacity.toString();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _capacityController.dispose();
    super.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = _selectedDate;

    final initialDate = selectedDate != null && !selectedDate.isBefore(today)
        ? selectedDate
        : today;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('sk', 'SK'),
      helpText: AppTexts.selectDate,
      cancelText: AppTexts.cancel,
      confirmText: AppTexts.ok,
    );

    if (pickedDate == null) {
      return;
    }

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

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  Future<void> _saveTrainingSession() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final durationMinutes = int.tryParse(_durationController.text.trim());
    final capacity = int.tryParse(_capacityController.text.trim());

    final trainerId = _isAdmin
        ? _selectedTrainerId
        : widget.item.session.trainerId;

    if (currentUser == null ||
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
      await _scheduleService.updateTrainingSession(
        item: widget.item,
        currentUser: currentUser,
        role: widget.role,
        trainerId: trainerId,
        startTime: startTime,
        durationMinutes: durationMinutes,
        capacity: capacity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingSessionUpdated)),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      final errorText = error.toString();

      final message = errorText.contains('training-session-overlap')
          ? AppTexts.trainingSessionOverlap
          : errorText.contains('capacity-lower-than-reservations')
          ? AppTexts.capacityLowerThanReservations
          : errorText.contains('trainer-not-owner-of-session')
          ? AppTexts.trainerCanCancelOnlyOwnSession
          : errorText.contains('trainer-cannot-cancel-started-session')
          ? AppTexts.trainerCannotCancelStartedSession
          : AppTexts.updateTrainingSessionError;

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
      appBar: AppBar(title: const Text(AppTexts.editTrainingSession)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.item.trainingType.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          if (_isAdmin) ...[
            _buildTrainerDropdown(),
            const SizedBox(height: 12),
          ],

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
            onPressed: _isSaving ? null : _saveTrainingSession,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppTexts.save),
          ),
        ],
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
