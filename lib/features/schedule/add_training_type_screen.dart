import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';
import 'schedule_service.dart';
/* Obrazovka/formulár pre admina na vytvorenie nového typu cvičenia, napríklad
   TRX, Joga alebo Tabata, spolu s popisom, predvoleným trvaním a kapacitou.*/
class AddTrainingTypeScreen extends StatefulWidget {
  const AddTrainingTypeScreen({super.key});

  @override
  State<AddTrainingTypeScreen> createState() => _AddTrainingTypeScreenState();
}

class _AddTrainingTypeScreenState extends State<AddTrainingTypeScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveTrainingType() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final defaultDurationMinutes =
        int.tryParse(_durationController.text.trim());
    final defaultCapacity = int.tryParse(_capacityController.text.trim());

    if (currentUser == null ||
        name.isEmpty ||
        description.isEmpty ||
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

    setState(() {
      _isSaving = true;
    });

    try {
      await _scheduleService.createTrainingType(
        name: name,
        description: description,
        defaultDurationMinutes: defaultDurationMinutes,
        defaultCapacity: defaultCapacity,
        currentUser: currentUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingTypeCreated)),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.saveError)),
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
        title: const Text(AppTexts.addTrainingType),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            enabled: !_isSaving,
            decoration: const InputDecoration(
              labelText: AppTexts.trainingName,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            enabled: !_isSaving,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: AppTexts.description,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _durationController,
            enabled: !_isSaving,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppTexts.defaultDuration,
              suffixText: AppTexts.minutes,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _capacityController,
            enabled: !_isSaving,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppTexts.defaultCapacity,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSaving ? null : _saveTrainingType,
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