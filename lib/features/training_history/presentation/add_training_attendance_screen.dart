import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../data/training_history_service.dart';

class AddTrainingAttendanceScreen extends StatefulWidget {
  const AddTrainingAttendanceScreen({super.key, required this.session});

  final TrainingHistorySession session;

  @override
  State<AddTrainingAttendanceScreen> createState() =>
      _AddTrainingAttendanceScreenState();
}

class _AddTrainingAttendanceScreenState
    extends State<AddTrainingAttendanceScreen> {
  final TrainingHistoryService _service = TrainingHistoryService();

  String? _selectedUserId;
  String? _selectedMembershipId;
  TrainingHistoryUserOption? _selectedUser;
  TrainingHistoryMembershipOption? _selectedMembership;
  bool _isSaving = false;

  Future<bool> _confirmAddAttendance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppTexts.addTrainingAttendance),
          content: const Text(AppTexts.addTrainingAttendanceQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppTexts.confirm),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _save() async {
    final selectedUser = _selectedUser;
    final selectedMembership = _selectedMembership;

    if (selectedUser == null || selectedMembership == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.fillAllFields)));
      return;
    }

    final confirmed = await _confirmAddAttendance();

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _service.addAttendanceFromHistory(
        session: widget.session,
        user: selectedUser,
        membership: selectedMembership,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.trainingAttendanceAdded)),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final errorText = error.toString();

      final message = errorText.contains('reservation-already-exists')
          ? AppTexts.userAlreadyHasReservationForTraining
          : AppTexts.trainingAttendanceAddError;

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

  Widget _buildUserDropdown(List<TrainingHistoryUserOption> users) {
    final selectedUserStillExists = users.any((user) {
      return user.id == _selectedUserId;
    });

    final safeSelectedUserId = selectedUserStillExists ? _selectedUserId : null;

    return DropdownButtonFormField<String>(
      initialValue: safeSelectedUserId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: AppTexts.selectAttendanceUser,
        border: OutlineInputBorder(),
      ),
      items: users.map((user) {
        return DropdownMenuItem<String>(
          value: user.id,
          child: Text(
            user.email.isEmpty
                ? user.displayName
                : '${user.displayName} • ${user.email}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _isSaving
          ? null
          : (value) {
              TrainingHistoryUserOption? selectedUser;

              for (final user in users) {
                if (user.id == value) {
                  selectedUser = user;
                  break;
                }
              }

              setState(() {
                _selectedUserId = value;
                _selectedUser = selectedUser;
                _selectedMembershipId = null;
                _selectedMembership = null;
              });
            },
    );
  }

  Widget _buildMembershipDropdown() {
    final selectedUser = _selectedUser;

    if (selectedUser == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<TrainingHistoryMembershipOption>>(
      stream: _service.watchUsableMembershipsForUser(
        userId: selectedUser.id,
        trainingStartTime: widget.session.startTime,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(AppTexts.membershipLoadError);
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final memberships = snapshot.data ?? [];

        if (memberships.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppTexts.noUsableMembershipsForAttendance),
            ),
          );
        }

        final selectedMembershipStillExists = memberships.any((membership) {
          return membership.id == _selectedMembershipId;
        });

        final safeSelectedMembershipId = selectedMembershipStillExists
            ? _selectedMembershipId
            : null;

        return DropdownButtonFormField<String>(
          initialValue: safeSelectedMembershipId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: AppTexts.selectAttendanceMembership,
            border: OutlineInputBorder(),
          ),
          items: memberships.map((membership) {
            return DropdownMenuItem<String>(
              value: membership.id,
              child: Text(
                membership.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _isSaving
              ? null
              : (value) {
                  TrainingHistoryMembershipOption? selectedMembership;

                  for (final membership in memberships) {
                    if (membership.id == value) {
                      selectedMembership = membership;
                      break;
                    }
                  }

                  setState(() {
                    _selectedMembershipId = value;
                    _selectedMembership = selectedMembership;
                  });
                },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.addTrainingAttendance)),
      body: StreamBuilder<List<TrainingHistoryUserOption>>(
        stream: _service.watchUsersForAttendance(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppTexts.usersLoadError));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text(AppTexts.noUsersForAttendance));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildUserDropdown(users),
              const SizedBox(height: 16),
              _buildMembershipDropdown(),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1),
                label: const Text(AppTexts.addTrainingAttendance),
              ),
            ],
          );
        },
      ),
    );
  }
}
