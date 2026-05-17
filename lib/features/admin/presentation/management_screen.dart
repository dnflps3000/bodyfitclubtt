import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../schedule/presentation/schedule_templates_management_screen.dart';
import '../../schedule/presentation/add_training_session_screen.dart';
import '../../schedule/presentation/training_types_management_screen.dart';
import 'users_management_screen.dart';
import '../../discounts/presentation/discount_requests_screen.dart';
import '../../memberships/presentation/assign_membership_screen.dart';
import '../../memberships/presentation/memberships_management_screen.dart';
import '../../reservations/presentation/attendance_screen.dart';
import '../../audit/presentation/audit_logs_screen.dart';
import '../../training_history/presentation/training_history_screen.dart';

/*Obrazovka pre admina a trénera, ktorá združuje správcovské akcie mimo 
  bežného používateľského zobrazenia.*/
class ManagementScreen extends StatelessWidget {
  const ManagementScreen({super.key, this.role, this.showAppBar = true});

  final String? role;
  final bool showAppBar;

  Future<void> _openTrainingTypesManagementScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TrainingTypesManagementScreen()),
    );
  }

  Future<void> _openScheduleTemplatesManagementScreen(
    BuildContext context,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScheduleTemplatesManagementScreen(),
      ),
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

  Future<void> _openMembershipsManagementScreen(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MembershipsManagementScreen()),
    );
  }

  Future<void> _openAuditLogsScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AuditLogsScreen()));
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

  Future<void> _openUsersManagementScreen(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UsersManagementScreen(currentUserId: currentUser.uid),
      ),
    );
  }

  Future<void> _openDiscountRequestsScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DiscountRequestsScreen()));
  }

  Future<void> _openTrainingHistoryScreen(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()));
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.xxl + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Text(
          AppTexts.managementDescription,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        if (isAdmin || isTrainer) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.fact_check,
            label: AppTexts.attendanceManagement,
            onPressed: () => _openAttendanceScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.manage_history,
            label: AppTexts.trainingHistory,
            onPressed: () => _openTrainingHistoryScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.group_outlined,
            label: AppTexts.usersManagement,
            onPressed: () => _openUsersManagementScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.discount_outlined,
            label: AppTexts.discountRequests,
            onPressed: () => _openDiscountRequestsScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin || isTrainer) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.card_membership,
            label: AppTexts.assignMembership,
            onPressed: () => _openAssignMembershipScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.manage_accounts_outlined,
            label: AppTexts.membershipsManagement,
            onPressed: () => _openMembershipsManagementScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.history_outlined,
            label: AppTexts.auditLogs,
            onPressed: () => _openAuditLogsScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.calendar_view_week,
            label: AppTexts.scheduleTemplatesManagement,
            onPressed: () => _openScheduleTemplatesManagementScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin || isTrainer) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.event_available,
            label: AppTexts.addTrainingSession,
            onPressed: () => _openAddTrainingSessionScreen(context),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],

        if (isAdmin) ...[
          _buildManagementButton(
            context: context,
            icon: Icons.fitness_center_outlined,
            label: AppTexts.trainingTypesManagement,
            onPressed: () => _openTrainingTypesManagementScreen(context),
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
