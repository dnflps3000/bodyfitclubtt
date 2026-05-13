import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';
import '../../audit/data/audit_log_service.dart';
import '../../memberships/presentation/memberships_management_screen.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key, required this.currentUserId});

  final String currentUserId;

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuditLogService _auditLogService = AuditLogService();

  Timer? _searchDebounce;
  String _searchQuery = '';
  String _selectedRoleFilter = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _searchQuery = value;
      });
    });
  }

  Stream<List<_ManagedUser>> _watchUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('email')
        .limit(200)
        .snapshots()
        .map((snapshot) {
          final users = snapshot.docs.map((document) {
            final data = document.data();

            return _ManagedUser(
              id: document.id,
              email: data['email'] as String? ?? '',
              firstName: data['firstName'] as String? ?? '',
              lastName: data['lastName'] as String? ?? '',
              publicName: data['publicName'] as String? ?? '',
              displayName: data['displayName'] as String? ?? '',
              role: data['role'] as String? ?? AppRoles.user,
              photoUrl: data['photoURL'] as String?,
              isActive: data['isActive'] as bool? ?? true,
            );
          }).toList();

          users.sort((a, b) {
            return a.displayLabel.toLowerCase().compareTo(
              b.displayLabel.toLowerCase(),
            );
          });

          return users;
        });
  }

  List<_ManagedUser> _filterUsers(List<_ManagedUser> users) {
    final query = _searchQuery.trim().toLowerCase();

    return users.where((user) {
      final matchesRole =
          _selectedRoleFilter.isEmpty || user.role == _selectedRoleFilter;

      final searchableText = [
        user.firstName,
        user.lastName,
        user.publicName,
        user.displayName,
        user.email,
        _roleLabel(user.role),
      ].join(' ').toLowerCase();

      final matchesQuery = query.isEmpty || searchableText.contains(query);

      return matchesRole && matchesQuery;
    }).toList();
  }

  String _roleLabel(String role) {
    switch (role) {
      case AppRoles.admin:
        return AppTexts.roleAdmin;
      case AppRoles.trainer:
        return AppTexts.roleTrainer;
      case AppRoles.user:
        return AppTexts.roleUser;
      default:
        return AppTexts.roleUnknown;
    }
  }

  bool _isManagerRole(String role) {
    return role == AppRoles.admin || role == AppRoles.trainer;
  }

  Map<String, dynamic> _userChanges({
    required _ManagedUser oldUser,
    required String firstName,
    required String lastName,
    required String publicName,
    required String email,
    required String role,
  }) {
    final changes = <String, dynamic>{};

    void addChange(String key, Object? oldValue, Object? newValue) {
      if (oldValue != newValue) {
        changes[key] = {'oldValue': oldValue, 'newValue': newValue};
      }
    }

    addChange('firstName', oldUser.firstName, firstName);
    addChange('lastName', oldUser.lastName, lastName);
    addChange('publicName', oldUser.publicName, publicName);
    addChange('email', oldUser.email, email);
    addChange('role', oldUser.role, role);

    return changes;
  }

  Future<void> _createUserAuditLog({
    required _ManagedUser user,
    required String action,
    required String title,
    required String description,
    Map<String, dynamic> changes = const {},
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await _auditLogService.createLogWithUsers(
      category: 'user',
      action: action,
      targetType: 'user',
      targetId: user.id,
      targetUserId: user.id,
      actor: currentUser,
      title: title,
      description: description,
      changes: changes,
    );
  }

  Future<void> _ensureUserCanLoseManagerRole({
    required _ManagedUser user,
    required String newRole,
  }) async {
    if (!_isManagerRole(user.role) || _isManagerRole(newRole)) {
      return;
    }

    final templatesSnapshot = await FirebaseFirestore.instance
        .collection('scheduleTemplates')
        .where('isActive', isEqualTo: true)
        .get();

    final isUsedByActiveTemplate = templatesSnapshot.docs.any((document) {
      final data = document.data();
      final trainerId = data['trainerId'] as String? ?? '';

      return trainerId == user.id;
    });

    if (isUsedByActiveTemplate) {
      throw Exception('user-used-by-template');
    }

    final sessionsSnapshot = await FirebaseFirestore.instance
        .collection('trainingSessions')
        .where('isActive', isEqualTo: true)
        .get();

    final now = DateTime.now();

    final isUsedByFutureSession = sessionsSnapshot.docs.any((document) {
      final data = document.data();
      final trainerId = data['trainerId'] as String? ?? '';
      final status = data['status'] as String? ?? '';
      final startTime = (data['startTime'] as Timestamp?)?.toDate();

      return trainerId == user.id &&
          status == 'scheduled' &&
          startTime != null &&
          startTime.isAfter(now);
    });

    if (isUsedByFutureSession) {
      throw Exception('user-used-by-future-session');
    }
  }

  Future<_DeactivationBlockInfo> _loadDeactivationBlockInfo(
    _ManagedUser user,
  ) async {
    if (user.id == widget.currentUserId) {
      throw Exception('cannot-deactivate-yourself');
    }

    await _ensureUserCanLoseManagerRole(user: user, newRole: AppRoles.user);

    final reservationsSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user.id)
        .where('status', isEqualTo: 'active')
        .get();

    final membershipsSnapshot = await FirebaseFirestore.instance
        .collection('memberships')
        .where('userId', isEqualTo: user.id)
        .where('status', isEqualTo: 'active')
        .get();

    return _DeactivationBlockInfo(
      activeReservationsCount: reservationsSnapshot.docs.length,
      activeMembershipsCount: membershipsSnapshot.docs.length,
    );
  }

  Future<void> _showDeactivationBlockedDialog({
    required _ManagedUser user,
    required _DeactivationBlockInfo blockInfo,
  }) async {
    final openMemberships = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.userCannotBeDeactivated),
          content: Text(
            '${AppTexts.userCannotBeDeactivatedDescription}\n\n'
            '${user.displayLabel}\n\n'
            '${AppTexts.userHasBlockingItems}\n'
            '- ${AppTexts.activeReservationsCount}: '
            '${blockInfo.activeReservationsCount}\n'
            '- ${AppTexts.activeMembershipsCount}: '
            '${blockInfo.activeMembershipsCount}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.back),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppTexts.showMemberships),
            ),
          ],
        );
      },
    );

    if (!mounted || openMemberships != true) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MembershipsManagementScreen()),
    );
  }

  String _userManagementErrorMessage(Object error) {
    final errorText = error.toString();

    if (errorText.contains('cannot-deactivate-yourself')) {
      return AppTexts.cannotDeactivateYourself;
    }

    if (errorText.contains('user-used-by-template')) {
      return AppTexts.userUsedByTemplate;
    }

    if (errorText.contains('user-used-by-future-session')) {
      return AppTexts.userUsedByFutureSession;
    }

    if (errorText.contains('user-has-active-reservations')) {
      return AppTexts.userHasActiveReservations;
    }

    if (errorText.contains('user-has-active-memberships')) {
      return AppTexts.userHasActiveMemberships;
    }

    return AppTexts.userUpdateError;
  }

  Future<void> _confirmDeactivateUser(_ManagedUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.deactivateUser),
          content: Text(
            '${AppTexts.deactivateUserQuestion}\n\n'
            '${user.displayLabel}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppTexts.deactivateUser),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      final blockInfo = await _loadDeactivationBlockInfo(user);

      if (blockInfo.hasBlockingItems) {
        if (!mounted) return;

        await _showDeactivationBlockedDialog(user: user, blockInfo: blockInfo);

        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'isActive': false,
        'deactivatedBy': widget.currentUserId,
        'deactivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _createUserAuditLog(
        user: user,
        action: 'user_deactivated',
        title: AppTexts.auditUserDeactivatedTitle,
        description: AppTexts.auditUserDeactivatedDescription,
        changes: {
          'isActive': {'oldValue': true, 'newValue': false},
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.userDeactivated)));
    } catch (error) {
      await _createUserAuditLog(
        user: user,
        action: 'user_deactivation_blocked',
        title: AppTexts.auditUserDeactivationBlockedTitle,
        description: AppTexts.auditUserDeactivationBlockedDescription,
        changes: {
          'reason': {'oldValue': null, 'newValue': error.toString()},
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_userManagementErrorMessage(error))),
      );
    }
  }

  Future<void> _confirmReactivateUser(_ManagedUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(AppTexts.reactivateUser),
          content: Text(
            '${AppTexts.reactivateUserQuestion}\n\n'
            '${user.displayLabel}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(AppTexts.reactivateUser),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'isActive': true,
        'reactivatedBy': widget.currentUserId,
        'reactivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _createUserAuditLog(
        user: user,
        action: 'user_reactivated',
        title: AppTexts.auditUserReactivatedTitle,
        description: AppTexts.auditUserReactivatedDescription,
        changes: {
          'isActive': {'oldValue': false, 'newValue': true},
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.userReactivated)));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.userUpdateError)));
    }
  }

  Future<void> _showEditUserDialog(_ManagedUser user) async {
    var firstName = user.firstName;
    var lastName = user.lastName;
    var publicName = user.publicName;
    var email = user.email;
    var selectedRole = user.role;
    var isSaving = false;

    final isCurrentUser = user.id == widget.currentUserId;

    final success = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> save() async {
              final trimmedFirstName = firstName.trim();
              final trimmedLastName = lastName.trim();
              final trimmedPublicName = publicName.trim();
              final trimmedEmail = email.trim().toLowerCase();

              if (trimmedEmail.isNotEmpty &&
                  (!trimmedEmail.contains('@') ||
                      !trimmedEmail.contains('.'))) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppTexts.invalidEmailFormat)),
                );
                return;
              }

              if (isCurrentUser && selectedRole != user.role) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppTexts.cannotChangeOwnRole)),
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                await _ensureUserCanLoseManagerRole(
                  user: user,
                  newRole: selectedRole,
                );

                final effectiveFirstName = trimmedFirstName.isNotEmpty
                    ? trimmedFirstName
                    : user.firstName.trim();

                final effectiveLastName = trimmedLastName.isNotEmpty
                    ? trimmedLastName
                    : user.lastName.trim();

                final displayName = '$effectiveFirstName $effectiveLastName'
                    .trim();

                final updates = <String, dynamic>{
                  'role': selectedRole,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (trimmedFirstName.isNotEmpty) {
                  updates['firstName'] = trimmedFirstName;
                }

                if (trimmedLastName.isNotEmpty) {
                  updates['lastName'] = trimmedLastName;
                }

                if (trimmedPublicName.isNotEmpty) {
                  updates['publicName'] = trimmedPublicName;
                }

                if (trimmedEmail != user.email.trim().toLowerCase()) {
                  updates['email'] = trimmedEmail;
                  updates['emailSource'] = 'admin';
                  updates['emailVerified'] = false;
                  updates['emailUpdatedBy'] = widget.currentUserId;
                  updates['emailUpdatedAt'] = FieldValue.serverTimestamp();
                }

                if (displayName.isNotEmpty) {
                  updates['displayName'] = displayName;
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .set(updates, SetOptions(merge: true));

                final effectivePublicName = trimmedPublicName.isNotEmpty
                    ? trimmedPublicName
                    : user.publicName.trim();

                final changes = _userChanges(
                  oldUser: user,
                  firstName: effectiveFirstName,
                  lastName: effectiveLastName,
                  publicName: effectivePublicName,
                  email: trimmedEmail,
                  role: selectedRole,
                );

                if (changes.isNotEmpty) {
                  final emailChanged =
                      trimmedEmail != user.email.trim().toLowerCase();

                  final onlyEmailChanged = emailChanged && changes.length == 1;

                  await _createUserAuditLog(
                    user: user,
                    action: selectedRole != user.role
                        ? 'user_role_changed'
                        : onlyEmailChanged
                        ? 'user_email_updated'
                        : 'user_updated',
                    title: selectedRole != user.role
                        ? AppTexts.auditUserRoleChangedTitle
                        : onlyEmailChanged
                        ? AppTexts.auditUserEmailUpdatedTitle
                        : AppTexts.auditUserUpdatedTitle,
                    description: selectedRole != user.role
                        ? AppTexts.auditUserRoleChangedDescription
                        : onlyEmailChanged
                        ? AppTexts.auditUserEmailUpdatedDescription
                        : AppTexts.auditUserUpdatedDescription,
                    changes: changes,
                  );
                }

                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop(true);
              } catch (error) {
                if (!mounted || !dialogContext.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_userManagementErrorMessage(error))),
                );

                setDialogState(() {
                  isSaving = false;
                });
              }
            }

            return AlertDialog(
              scrollable: true,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              title: const Text(AppTexts.editUser),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: firstName,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText: AppTexts.firstName,
                      ),
                      onChanged: (value) {
                        firstName = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: lastName,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText: AppTexts.lastName,
                      ),
                      onChanged: (value) {
                        lastName = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: publicName,
                      enabled: !isSaving,
                      decoration: const InputDecoration(
                        labelText: AppTexts.publicName,
                        hintText: AppTexts.publicNameHint,
                      ),
                      onChanged: (value) {
                        publicName = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: email,
                      enabled: !isSaving,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: AppTexts.email,
                      ),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: AppTexts.role,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: AppRoles.user,
                          child: Text(AppTexts.roleUser),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.trainer,
                          child: Text(AppTexts.roleTrainer),
                        ),
                        DropdownMenuItem(
                          value: AppRoles.admin,
                          child: Text(AppTexts.roleAdmin),
                        ),
                      ],
                      onChanged: isSaving || isCurrentUser
                          ? null
                          : (role) {
                              if (role == null) return;

                              setDialogState(() {
                                selectedRole = role;
                              });
                            },
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(height: 8),
                      const Text(
                        AppTexts.cannotChangeOwnRole,
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text(
                        AppTexts.changeRoleWarning,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text(AppTexts.cancel),
                ),
                FilledButton(
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppTexts.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || success != true) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppTexts.userUpdated)));
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: AppTexts.searchUsers,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedRoleFilter,
          decoration: const InputDecoration(labelText: AppTexts.role),
          items: const [
            DropdownMenuItem(value: '', child: Text(AppTexts.allRoles)),
            DropdownMenuItem(
              value: AppRoles.user,
              child: Text(AppTexts.roleUser),
            ),
            DropdownMenuItem(
              value: AppRoles.trainer,
              child: Text(AppTexts.roleTrainer),
            ),
            DropdownMenuItem(
              value: AppRoles.admin,
              child: Text(AppTexts.roleAdmin),
            ),
          ],
          onChanged: (role) {
            setState(() {
              _selectedRoleFilter = role ?? '';
            });
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(_ManagedUser user) {
    final isCurrentUser = user.id == widget.currentUserId;
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: hasPhoto
                  ? ResizeImage(
                      NetworkImage(user.photoUrl!),
                      width: 96,
                      height: 96,
                    )
                  : null,
              child: hasPhoto ? null : const Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (user.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(user.email),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${AppTexts.role}: ${_roleLabel(user.role)}'
                    '${isCurrentUser ? ' • vy' : ''}'
                    '${!user.isActive ? ' • ${AppTexts.inactiveUser}' : ''}',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: AppTexts.editUser,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditUserDialog(user),
                ),
                if (!isCurrentUser && user.isActive)
                  IconButton(
                    tooltip: AppTexts.deactivateUser,
                    icon: const Icon(Icons.person_off_outlined),
                    onPressed: () => _confirmDeactivateUser(user),
                  ),
                if (!isCurrentUser && !user.isActive)
                  IconButton(
                    tooltip: AppTexts.reactivateUser,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    onPressed: () => _confirmReactivateUser(user),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.usersManagement)),
      body: StreamBuilder<List<_ManagedUser>>(
        stream: _watchUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppTexts.usersLoadError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = _filterUsers(snapshot.data ?? []);

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: users.isEmpty ? 2 : users.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFilters();
              }

              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    AppTexts.noUsersFound,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return _buildUserCard(users[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _ManagedUser {
  const _ManagedUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.publicName,
    required this.displayName,
    required this.role,
    required this.photoUrl,
    required this.isActive,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String publicName;
  final String displayName;
  final String role;
  final String? photoUrl;
  final bool isActive;

  String get displayLabel {
    if (publicName.trim().isNotEmpty) {
      return publicName.trim();
    }

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    if (displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    if (email.trim().isNotEmpty) {
      return email.trim();
    }

    return AppTexts.unknownUser;
  }
}

class _DeactivationBlockInfo {
  const _DeactivationBlockInfo({
    required this.activeReservationsCount,
    required this.activeMembershipsCount,
  });

  final int activeReservationsCount;
  final int activeMembershipsCount;

  bool get hasBlockingItems {
    return activeReservationsCount > 0 || activeMembershipsCount > 0;
  }
}
