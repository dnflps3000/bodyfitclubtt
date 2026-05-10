import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../data/membership_service.dart';
import '../domain/membership.dart';
import 'membership_detail_screen.dart';

class MembershipsManagementScreen extends StatefulWidget {
  const MembershipsManagementScreen({super.key});

  @override
  State<MembershipsManagementScreen> createState() =>
      _MembershipsManagementScreenState();
}

class _MembershipsManagementScreenState
    extends State<MembershipsManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  String _searchQuery = '';
  String _selectedStatusFilter = '';

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
    });
  }

  Stream<Map<String, _MembershipUserInfo>> _watchUsersMap() {
    return FirebaseFirestore.instance.collection('users').snapshots().map((
      snapshot,
    ) {
      final users = <String, _MembershipUserInfo>{};

      for (final document in snapshot.docs) {
        final data = document.data();

        users[document.id] = _MembershipUserInfo(
          id: document.id,
          email: data['email'] as String? ?? '',
          firstName: data['firstName'] as String? ?? '',
          lastName: data['lastName'] as String? ?? '',
          publicName: data['publicName'] as String? ?? '',
          displayName: data['displayName'] as String? ?? '',
        );
      }

      return users;
    });
  }

  List<Membership> _filterMemberships({
    required List<Membership> memberships,
    required Map<String, _MembershipUserInfo> usersById,
  }) {
    final query = _searchQuery.trim().toLowerCase();

    return memberships.where((membership) {
      final matchesStatus =
          _selectedStatusFilter.isEmpty ||
          membership.status == _selectedStatusFilter;

      final user = usersById[membership.userId];

      final searchableText = [
        membership.planName,
        membership.status,
        membership.userId,
        user?.displayLabel ?? '',
        user?.email ?? '',
      ].join(' ').toLowerCase();

      final matchesQuery = query.isEmpty || searchableText.contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day.$month.$year';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return AppTexts.membershipStatusActive;
      case 'inactive':
        return AppTexts.membershipStatusInactive;
      case 'cancelled':
        return AppTexts.membershipStatusCancelled;
      default:
        return status;
    }
  }

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: AppTexts.searchMemberships,
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedStatusFilter,
          decoration: const InputDecoration(labelText: AppTexts.status),
          items: const [
            DropdownMenuItem(
              value: '',
              child: Text(AppTexts.allMembershipStatuses),
            ),
            DropdownMenuItem(
              value: 'active',
              child: Text(AppTexts.membershipStatusActive),
            ),
            DropdownMenuItem(
              value: 'inactive',
              child: Text(AppTexts.membershipStatusInactive),
            ),
            DropdownMenuItem(
              value: 'cancelled',
              child: Text(AppTexts.membershipStatusCancelled),
            ),
          ],
          onChanged: (status) {
            setState(() {
              _selectedStatusFilter = status ?? '';
            });
          },
        ),
      ],
    );
  }

  Widget _buildMembershipCard({
    required BuildContext context,
    required Membership membership,
    required _MembershipUserInfo? user,
  }) {
    final userLabel = user?.displayLabel ?? membership.userId;
    final entriesReserved = membership.entriesReserved ?? 0;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.card_membership),
        title: Text(membership.planName),
        subtitle: Text(
          '${AppTexts.client}: $userLabel\n'
          '${user?.email.isNotEmpty == true ? '${user!.email}\n' : ''}'
          '${AppTexts.status}: ${_statusLabel(membership.status)}\n'
          '${AppTexts.validUntil}: ${_formatDate(membership.validUntil)}\n'
          '${AppTexts.entriesRemaining}: ${membership.entriesRemaining ?? '-'}'
          '${entriesReserved > 0 ? '\n${AppTexts.entriesReserved}: $entriesReserved' : ''}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  MembershipDetailScreen(membership: membership, isAdmin: true),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.membershipsManagement)),
      body: StreamBuilder<Map<String, _MembershipUserInfo>>(
        stream: _watchUsersMap(),
        builder: (context, usersSnapshot) {
          final usersById = usersSnapshot.data ?? {};

          return StreamBuilder<List<Membership>>(
            stream: MembershipService().watchAllMemberships(),
            builder: (context, membershipsSnapshot) {
              if (membershipsSnapshot.hasError) {
                return const Center(child: Text(AppTexts.membershipLoadError));
              }

              if (membershipsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final memberships = _filterMemberships(
                memberships: membershipsSnapshot.data ?? [],
                usersById: usersById,
              );

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  32 + MediaQuery.of(context).padding.bottom,
                ),
                itemCount: memberships.length + 1,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildFilters();
                  }

                  if (memberships.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        AppTexts.noMemberships,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final membership = memberships[index - 1];

                  return _buildMembershipCard(
                    context: context,
                    membership: membership,
                    user: usersById[membership.userId],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MembershipUserInfo {
  const _MembershipUserInfo({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.publicName,
    required this.displayName,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String publicName;
  final String displayName;

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

    return id;
  }
}
