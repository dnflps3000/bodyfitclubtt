import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_roles.dart';
import '../../core/theme/app_texts.dart';
import 'membership_plan.dart';
import 'membership_service.dart';

/* Obrazovka pre admina na ručné priradenie permanentky konkrétnemu používateľovi. */
class AssignMembershipScreen extends StatefulWidget {
  const AssignMembershipScreen({super.key});

  @override
  State<AssignMembershipScreen> createState() => _AssignMembershipScreenState();
}

class _AssignMembershipScreenState extends State<AssignMembershipScreen> {
  final MembershipService _membershipService = MembershipService();

  String? _selectedUserId;
  String? _selectedPlanId;
  bool _isSaving = false;

  Stream<List<_UserOption>> _watchUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: AppRoles.user)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((document) {
        final data = document.data();

        return _UserOption(
          id: document.id,
          name: data['displayName'] as String? ?? 'Neznámy používateľ',
          email: data['email'] as String?,
          isActive: data['isActive'] as bool? ?? true,
        );
      }).where((user) {
        return user.isActive;
      }).toList();

      users.sort((a, b) => a.name.compareTo(b.name));

      return users;
    });
  }

  MembershipPlan? _findSelectedPlan(List<MembershipPlan> plans) {
    for (final plan in plans) {
      if (plan.id == _selectedPlanId) {
        return plan;
      }
    }

    return null;
  }

  Future<void> _assignMembership(List<MembershipPlan> plans) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final selectedPlan = _findSelectedPlan(plans);

    if (currentUser == null ||
        _selectedUserId == null ||
        selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.fillAllFields)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _membershipService.assignMembershipToUser(
        plan: selectedPlan,
        userId: _selectedUserId!,
        currentUser: currentUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.membershipAssigned)),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.membershipAssignError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildUserDropdown() {
    return StreamBuilder<List<_UserOption>>(
      stream: _watchUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(AppTexts.usersLoadError);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(),
          );
        }

        final users = snapshot.data ?? [];

        return DropdownButtonFormField<String>(
          initialValue: _selectedUserId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: AppTexts.client,
          ),
          items: users.map((user) {
            final subtitle = user.email == null ? '' : ' (${user.email})';

            return DropdownMenuItem<String>(
              value: user.id,
              child: Text(
                '${user.name}$subtitle',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: _isSaving
              ? null
              : (userId) {
                  setState(() {
                    _selectedUserId = userId;
                  });
                },
          hint: const Text(AppTexts.selectUser),
        );
      },
    );
  }

  Widget _buildPlanDropdown(List<MembershipPlan> plans) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPlanId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: AppTexts.membershipPlan,
      ),
      items: plans.map((plan) {
        return DropdownMenuItem<String>(
          value: plan.id,
          child: Text(
            '${plan.name} – ${plan.price} ${plan.currency}',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: _isSaving
          ? null
          : (planId) {
              setState(() {
                _selectedPlanId = planId;
              });
            },
      hint: const Text(AppTexts.selectMembershipPlan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.assignMembership),
      ),
      body: StreamBuilder<List<MembershipPlan>>(
        stream: _membershipService.watchActiveMembershipPlans(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(AppTexts.membershipPlansLoadError),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final plans = snapshot.data ?? [];

          if (plans.isEmpty) {
            return const Center(
              child: Text(AppTexts.membershipPlansLoadError),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildUserDropdown(),
              const SizedBox(height: 12),
              _buildPlanDropdown(plans),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : () => _assignMembership(plans),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppTexts.assignMembership),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserOption {
  const _UserOption({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? email;
  final bool isActive;
}