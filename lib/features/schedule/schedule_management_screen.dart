import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';
import 'add_schedule_template_screen.dart';
import 'add_training_session_screen.dart';
import 'add_training_type_screen.dart';

/*Obrazovka pre admina, ktorá združuje správcovské akcie rozvrhu mimo 
  bežného používateľského zobrazenia.*/
class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({super.key});

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

  Widget _buildManagementButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.scheduleManagement),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppTexts.scheduleManagementDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildManagementButton(
            context: context,
            icon: Icons.add,
            label: AppTexts.addTrainingType,
            onPressed: () => _openAddTrainingTypeScreen(context),
          ),
          const SizedBox(height: 12),
          _buildManagementButton(
            context: context,
            icon: Icons.calendar_view_week,
            label: AppTexts.addScheduleTemplate,
            onPressed: () => _openAddScheduleTemplateScreen(context),
          ),
          const SizedBox(height: 12),
          _buildManagementButton(
            context: context,
            icon: Icons.event_available,
            label: AppTexts.addTrainingSession,
            onPressed: () => _openAddTrainingSessionScreen(context),
          ),
        ],
      ),
    );
  }
}