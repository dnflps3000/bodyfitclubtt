import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import 'add_schedule_template_screen.dart';
import 'add_training_session_screen.dart';
import 'add_training_type_screen.dart';
import '../../memberships/presentation/assign_membership_screen.dart';
import '../../reservations/presentation/attendance_screen.dart';

/*Obrazovka pre admina a trénera, ktorá združuje správcovské akcie mimo 
  bežného používateľského zobrazenia.*/
class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({
    super.key,
    this.role,
    this.showAppBar = true,
  });

  final String? role;
  final bool showAppBar;

  Future<void> _openAddTrainingTypeScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTrainingTypeScreen()));
  }

  Future<void> _openAddScheduleTemplateScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddScheduleTemplateScreen()),
    );
  }

  Future<void> _openAddTrainingSessionScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTrainingSessionScreen()));
  }

  Future<void> _openAssignMembershipScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AssignMembershipScreen()));
  }

  Future<void> _openAttendanceScreen(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          trainerId: role == AppRoles.trainer ? currentUser?.uid : null,
        ),
      ),
    );
  }

  void _showUsersManagementComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppTexts.usersManagementComingSoon)),
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
    final isAdmin = role == AppRoles.admin;
    final isTrainer = role == AppRoles.trainer;

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          AppTexts.managementDescription,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        if (isAdmin || isTrainer) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.fact_check,
            label: AppTexts.attendanceManagement,
            onPressed: () => _openAttendanceScreen(context),
          ),
          const SizedBox(height: 12),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.group_outlined,
            label: AppTexts.usersManagement,
            onPressed: () => _showUsersManagementComingSoon(context),
          ),
          const SizedBox(height: 12),
        ],

        if (isAdmin || isTrainer) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.card_membership,
            label: AppTexts.assignMembership,
            onPressed: () => _openAssignMembershipScreen(context),
          ),
          const SizedBox(height: 12),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.calendar_view_week,
            label: AppTexts.scheduleTemplatesManagement,
            onPressed: () => _openAddScheduleTemplateScreen(context),
          ),
          const SizedBox(height: 12),
        ],

        if (isAdmin || isTrainer) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.event_available,
            label: AppTexts.addTrainingSession,
            onPressed: () => _openAddTrainingSessionScreen(context),
          ),
          const SizedBox(height: 12),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.add,
            label: AppTexts.addTrainingType,
            onPressed: () => _openAddTrainingTypeScreen(context),
          ),
        ],
      ],
    );

    if (!showAppBar) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.management)),
      body: content,
    );
  }
}
