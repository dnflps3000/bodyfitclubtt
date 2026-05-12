import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_texts.dart';
import '../data/audit_log_service.dart';
import '../domain/audit_log.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final AuditLogService _auditLogService = AuditLogService();
  final TextEditingController _searchController = TextEditingController();

  Future<List<AuditLog>>? _logsFuture;
  Timer? _searchDebounce;

  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedAction = '';
  String _selectedActorRole = '';
  String _selectedPeriod = '7_days';

  @override
  void initState() {
    super.initState();
    _reloadLogs();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _searchQuery = value;
      });

      _reloadLogs();
    });
  }

  void _reloadLogs() {
    final now = DateTime.now();

    DateTime? dateFrom;
    DateTime? dateTo;

    switch (_selectedPeriod) {
      case 'today':
        dateFrom = DateTime(now.year, now.month, now.day);
        dateTo = now;
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        dateFrom = DateTime(yesterday.year, yesterday.month, yesterday.day);
        dateTo = DateTime(now.year, now.month, now.day);
        break;
      case '7_days':
        dateFrom = now.subtract(const Duration(days: 7));
        dateTo = now;
        break;
      case '30_days':
        dateFrom = now.subtract(const Duration(days: 30));
        dateTo = now;
        break;
      case 'all':
        dateFrom = null;
        dateTo = null;
        break;
    }

    setState(() {
      _logsFuture = _auditLogService.loadAuditLogs(
        searchQuery: _searchQuery,
        category: _selectedCategory,
        action: _selectedAction,
        actorRole: _selectedActorRole,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    });
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'membership':
        return AppTexts.auditCategoryMemberships;
      case 'reservation':
        return AppTexts.auditCategoryReservations;
      case 'attendance':
        return AppTexts.auditCategoryAttendance;
      case 'user':
        return AppTexts.auditCategoryUsers;
      case 'schedule':
        return AppTexts.auditCategorySchedule;
      case 'message':
        return AppTexts.auditCategoryMessages;
      case 'payment':
        return AppTexts.auditCategoryPayments;
      case 'profile':
        return AppTexts.auditCategoryProfile;
      default:
        return category;
    }
  }

  String _actorRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return AppTexts.roleAdmin;
      case 'trainer':
        return AppTexts.roleTrainer;
      case 'user':
        return AppTexts.roleUser;
      default:
        return role.isEmpty ? '-' : role;
    }
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: AppTexts.searchAuditLogs,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(labelText: AppTexts.auditCategory),
          items: const [
            DropdownMenuItem(
              value: '',
              child: Text(AppTexts.auditAllCategories),
            ),
            DropdownMenuItem(
              value: 'membership',
              child: Text(AppTexts.auditCategoryMemberships),
            ),
            DropdownMenuItem(
              value: 'reservation',
              child: Text(AppTexts.auditCategoryReservations),
            ),
            DropdownMenuItem(
              value: 'attendance',
              child: Text(AppTexts.auditCategoryAttendance),
            ),
            DropdownMenuItem(
              value: 'user',
              child: Text(AppTexts.auditCategoryUsers),
            ),
            DropdownMenuItem(
              value: 'schedule',
              child: Text(AppTexts.auditCategorySchedule),
            ),
            DropdownMenuItem(
              value: 'message',
              child: Text(AppTexts.auditCategoryMessages),
            ),
            DropdownMenuItem(
              value: 'payment',
              child: Text(AppTexts.auditCategoryPayments),
            ),
            DropdownMenuItem(
              value: 'profile',
              child: Text(AppTexts.auditCategoryProfile),
            ),
          ],
          onChanged: (value) {
            _selectedCategory = value ?? '';
            _reloadLogs();
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedAction,
          decoration: const InputDecoration(labelText: AppTexts.auditAction),
          items: const [
            DropdownMenuItem(value: '', child: Text(AppTexts.auditAllActions)),

            DropdownMenuItem(
              value: 'assigned',
              child: Text(AppTexts.auditActionMembershipAssigned),
            ),
            DropdownMenuItem(
              value: 'purchased',
              child: Text(AppTexts.auditActionMembershipPurchased),
            ),
            DropdownMenuItem(
              value: 'membership_updated',
              child: Text(AppTexts.auditActionMembershipUpdated),
            ),
            DropdownMenuItem(
              value: 'membership_status_changed',
              child: Text(AppTexts.auditActionMembershipStatusChanged),
            ),
            DropdownMenuItem(
              value: 'membership_entries_changed',
              child: Text(AppTexts.auditActionMembershipEntriesChanged),
            ),
            DropdownMenuItem(
              value: 'membership_reservation_cancelled',
              child: Text(AppTexts.auditActionMembershipReservationCancelled),
            ),
            DropdownMenuItem(
              value: 'membership_all_reservations_cancelled',
              child: Text(
                AppTexts.auditActionMembershipAllReservationsCancelled,
              ),
            ),

            DropdownMenuItem(
              value: 'created',
              child: Text(AppTexts.auditActionReservationCreated),
            ),
            DropdownMenuItem(
              value: 'cancelled',
              child: Text(AppTexts.auditActionReservationCancelled),
            ),
            DropdownMenuItem(
              value: 'attendance_marked_attended',
              child: Text(AppTexts.auditActionAttendanceAttended),
            ),
            DropdownMenuItem(
              value: 'attendance_marked_no_show',
              child: Text(AppTexts.auditActionAttendanceNoShow),
            ),

            DropdownMenuItem(
              value: 'training_type_created',
              child: Text(AppTexts.auditActionTrainingTypeCreated),
            ),
            DropdownMenuItem(
              value: 'training_type_updated',
              child: Text(AppTexts.auditActionTrainingTypeUpdated),
            ),
            DropdownMenuItem(
              value: 'training_type_deactivated',
              child: Text(AppTexts.auditActionTrainingTypeDeactivated),
            ),
            DropdownMenuItem(
              value: 'training_session_created',
              child: Text(AppTexts.auditActionTrainingSessionCreated),
            ),
            DropdownMenuItem(
              value: 'training_session_updated',
              child: Text(AppTexts.auditActionTrainingSessionUpdated),
            ),
            DropdownMenuItem(
              value: 'training_session_time_changed',
              child: Text(AppTexts.auditActionTrainingSessionTimeChanged),
            ),
            DropdownMenuItem(
              value: 'training_session_cancelled',
              child: Text(AppTexts.auditActionTrainingSessionCancelled),
            ),
            DropdownMenuItem(
              value: 'schedule_template_created',
              child: Text(AppTexts.auditActionScheduleTemplateCreated),
            ),
            DropdownMenuItem(
              value: 'schedule_template_updated',
              child: Text(AppTexts.auditActionScheduleTemplateUpdated),
            ),
            DropdownMenuItem(
              value: 'schedule_template_deactivated',
              child: Text(AppTexts.auditActionScheduleTemplateDeactivated),
            ),

            DropdownMenuItem(
              value: 'user_updated',
              child: Text(AppTexts.auditActionUserUpdated),
            ),
            DropdownMenuItem(
              value: 'user_role_changed',
              child: Text(AppTexts.auditActionUserRoleChanged),
            ),
            DropdownMenuItem(
              value: 'user_deactivation_blocked',
              child: Text(AppTexts.auditActionUserDeactivationBlocked),
            ),
            DropdownMenuItem(
              value: 'user_deactivated',
              child: Text(AppTexts.auditActionUserDeactivated),
            ),

            DropdownMenuItem(
              value: 'public_message_created',
              child: Text(AppTexts.auditActionPublicMessageCreated),
            ),
            DropdownMenuItem(
              value: 'public_message_updated',
              child: Text(AppTexts.auditActionPublicMessageUpdated),
            ),
            DropdownMenuItem(
              value: 'public_message_deleted',
              child: Text(AppTexts.auditActionPublicMessageDeleted),
            ),
            DropdownMenuItem(
              value: 'profile_completed',
              child: Text(AppTexts.auditActionProfileCompleted),
            ),
            DropdownMenuItem(
              value: 'profile_updated',
              child: Text(AppTexts.auditActionProfileUpdated),
            ),
            DropdownMenuItem(
              value: 'profile_photo_updated',
              child: Text(AppTexts.auditActionProfilePhotoUpdated),
            ),
            DropdownMenuItem(
              value: 'profile_photo_removed',
              child: Text(AppTexts.auditActionProfilePhotoRemoved),
            ),
            DropdownMenuItem(
              value: 'payment_started',
              child: Text(AppTexts.auditActionPaymentStarted),
            ),
            DropdownMenuItem(
              value: 'payment_succeeded',
              child: Text(AppTexts.auditActionPaymentSucceeded),
            ),
            DropdownMenuItem(
              value: 'payment_failed',
              child: Text(AppTexts.auditActionPaymentFailed),
            ),
            DropdownMenuItem(
              value: 'user_email_completed',
              child: Text(AppTexts.auditActionUserEmailCompleted),
            ),
            DropdownMenuItem(
              value: 'user_email_updated',
              child: Text(AppTexts.auditActionUserEmailUpdated),
            ),
            DropdownMenuItem(
              value: 'user_reactivated',
              child: Text(AppTexts.auditActionUserReactivated),
            ),
          ],
          onChanged: (value) {
            _selectedAction = value ?? '';
            _reloadLogs();
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedActorRole,
          decoration: const InputDecoration(labelText: AppTexts.auditActorRole),
          items: const [
            DropdownMenuItem(
              value: '',
              child: Text(AppTexts.auditAllActorRoles),
            ),
            DropdownMenuItem(value: 'admin', child: Text(AppTexts.roleAdmin)),
            DropdownMenuItem(
              value: 'trainer',
              child: Text(AppTexts.roleTrainer),
            ),
            DropdownMenuItem(value: 'user', child: Text(AppTexts.roleUser)),
          ],
          onChanged: (value) {
            _selectedActorRole = value ?? '';
            _reloadLogs();
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedPeriod,
          decoration: const InputDecoration(labelText: AppTexts.auditPeriod),
          items: const [
            DropdownMenuItem(value: 'today', child: Text(AppTexts.today)),
            DropdownMenuItem(
              value: 'yesterday',
              child: Text(AppTexts.yesterday),
            ),
            DropdownMenuItem(value: '7_days', child: Text(AppTexts.last7Days)),
            DropdownMenuItem(
              value: '30_days',
              child: Text(AppTexts.last30Days),
            ),
            DropdownMenuItem(value: 'all', child: Text(AppTexts.allTime)),
          ],
          onChanged: (value) {
            _selectedPeriod = value ?? '7_days';
            _reloadLogs();
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _reloadLogs,
            icon: const Icon(Icons.refresh),
            label: const Text(AppTexts.refresh),
          ),
        ),
      ],
    );
  }

  Widget _buildLogCard(AuditLog log) {
    final actor = [
      log.actorName.isNotEmpty ? log.actorName : log.actorEmail,
      _actorRoleLabel(log.actorRole),
    ].where((value) => value.trim().isNotEmpty).join(' · ');

    final targetUser = [
      log.targetUserName,
      log.targetUserEmail,
    ].where((value) => value.trim().isNotEmpty).join(' · ');

    return Card(
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(log.title.isEmpty ? log.action : log.title),
        subtitle: Text(
          '${_formatDateTime(log.createdAt)}\n'
          '${AppTexts.auditCategory}: ${_categoryLabel(log.category)}\n'
          '${AppTexts.auditActor}: ${actor.isEmpty ? '-' : actor}'
          '${targetUser.isNotEmpty ? '\n${AppTexts.client}: $targetUser' : ''}'
          '${log.description.isNotEmpty ? '\n${log.description}' : ''}',
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.auditLogs)),
      body: FutureBuilder<List<AuditLog>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          final logs = snapshot.data ?? [];
          final hasStatusRow =
              snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError ||
              logs.isEmpty;

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: logs.length + 1 + (hasStatusRow ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFilters();
              }

              if (hasStatusRow && index == 1) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      AppTexts.auditLogsLoadError,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    AppTexts.noAuditLogs,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final logIndex = hasStatusRow ? index - 2 : index - 1;

              return _buildLogCard(logs[logIndex]);
            },
          );
        },
      ),
    );
  }
}
