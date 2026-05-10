import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_texts.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key, required this.currentUserId});

  final String currentUserId;

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

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

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _searchQuery = value;
      });
    });
  }

  Stream<List<_ManagedUser>> _watchUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((
      snapshot,
    ) {
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

  Future<void> _ensureUserCanBeDeactivated(_ManagedUser user) async {
    if (user.id == widget.currentUserId) {
      throw Exception('cannot-deactivate-yourself');
    }

    await _ensureUserCanLoseManagerRole(user: user, newRole: AppRoles.user);

    final reservationsSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user.id)
        .get();

    final hasActiveReservations = reservationsSnapshot.docs.any((document) {
      final data = document.data();
      final status = data['status'] as String? ?? '';

      return status == 'active';
    });

    if (hasActiveReservations) {
      throw Exception('user-has-active-reservations');
    }

    final membershipsSnapshot = await FirebaseFirestore.instance
        .collection('memberships')
        .where('userId', isEqualTo: user.id)
        .get();

    final hasActiveMemberships = membershipsSnapshot.docs.any((document) {
      final data = document.data();
      final status = data['status'] as String? ?? '';

      return status == 'active';
    });

    if (hasActiveMemberships) {
      throw Exception('user-has-active-memberships');
    }
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
      await _ensureUserCanBeDeactivated(user);

      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'isActive': false,
        'deactivatedBy': widget.currentUserId,
        'deactivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.userDeactivated)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_userManagementErrorMessage(error))),
      );
    }
  }

  Future<void> _showEditUserDialog(_ManagedUser user) async {
    var firstName = user.firstName;
    var lastName = user.lastName;
    var publicName = user.publicName;
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

                if (displayName.isNotEmpty) {
                  updates['displayName'] = displayName;
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .set(updates, SetOptions(merge: true));

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
              backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
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
                if (user.isActive)
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
