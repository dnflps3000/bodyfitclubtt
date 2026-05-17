import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../auth/data/auth_service.dart';
import '../../discounts/presentation/request_discount_screen.dart';
import '../data/account_service.dart';
import 'edit_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.user});

  final User user;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AccountService _accountService = AccountService();
  bool _isDeletingAccount = false;

  String _roleLabel(String? role) {
    switch (role) {
      case AppRoles.user:
        return AppTexts.roleUser;
      case AppRoles.trainer:
        return AppTexts.roleTrainer;
      case AppRoles.admin:
        return AppTexts.roleAdmin;
      default:
        return AppTexts.roleUnknown;
    }
  }

  String _discountTypeLabel(String type) {
    switch (type) {
      case 'student':
        return AppTexts.discountTypeStudent;
      case 'senior':
        return AppTexts.discountTypeSenior;
      case 'ztp':
        return AppTexts.discountTypeZtp;
      case 'individual':
        return AppTexts.discountTypeIndividual;
      case 'normal':
        return AppTexts.discountTypeNormal;
      default:
        return AppTexts.discountTypeNormal;
    }
  }

  String _discountStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return AppTexts.discountStatusPending;
      case 'approved':
        return AppTexts.discountStatusApproved;
      case 'rejected':
        return AppTexts.discountStatusRejected;
      case 'expired':
        return AppTexts.discountStatusExpired;
      case 'none':
        return AppTexts.discountStatusNone;
      default:
        return AppTexts.discountStatusNone;
    }
  }

  String _formatDiscountDate(DateTime? date) {
    if (date == null) {
      return AppTexts.notSet;
    }

    return '${date.day}. ${date.month}. ${date.year}';
  }

  Future<void> _requestAccountDeletion() async {
    final messenger = ScaffoldMessenger.of(context);
    var reason = '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text(AppTexts.deleteAccountRequestTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppTexts.deleteAccountRequestDescription),
              const SizedBox(height: AppSpacing.cardGap),
              const Text(AppTexts.deleteAccountConfirm),
              const SizedBox(height: AppSpacing.cardGap),
              TextField(
                decoration: const InputDecoration(
                  labelText: AppTexts.deleteAccountReason,
                ),
                maxLines: 2,
                onChanged: (value) {
                  reason = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(AppTexts.cancel),
            ),
            FilledButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(AppTexts.deleteAccountRequest),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      await _accountService.requestAccountDeletion(reason: reason);

      await AuthService().signOut();

      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.deleteAccountRequestSent)),
      );
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;

      setState(() {
        _isDeletingAccount = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.code == 'failed-precondition'
                ? AppTexts.deleteAccountBlockedActiveReservations
                : AppTexts.deleteAccountRequestError,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isDeletingAccount = false;
      });

      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.deleteAccountRequestError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final firstName = data?['firstName'] as String? ?? '';
        final lastName = data?['lastName'] as String? ?? '';
        final displayName = data?['displayName'] as String?;
        final publicName = data?['publicName'] as String? ?? '';
        final email = data?['email'] as String?;
        final role = data?['role'] as String?;
        final isRegularUser = role == AppRoles.user;
        final canRequestAccountDeletion = isRegularUser;
        final discountType = data?['discountType'] as String? ?? 'normal';
        final discountStatus = data?['discountStatus'] as String? ?? 'none';
        final discountValidUntil = (data?['discountValidUntil'] as Timestamp?)
            ?.toDate();

        final canRequestDiscount =
            isRegularUser &&
            discountStatus != 'pending' &&
            discountStatus != 'approved';
        final photoUrl = data?['photoURL'] as String? ?? widget.user.photoURL;
        final providerPhotoUrl = data?['providerPhotoURL'] as String?;

        final visibleDisplayName = displayName?.isNotEmpty == true
            ? displayName!
            : widget.user.displayName?.isNotEmpty == true
            ? widget.user.displayName!
            : AppTexts.profile;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            CircleAvatar(
              radius: 42,
              child: ClipOval(
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        memCacheWidth: 168,
                        memCacheHeight: 168,
                        placeholder: (context, url) {
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const Icon(Icons.person, size: 42);
                        },
                      )
                    : const Icon(Icons.person, size: 42),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Center(
              child: Text(
                visibleDisplayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text(AppTexts.email),
                    subtitle: Text(
                      email ?? widget.user.email ?? AppTexts.emailNotProvided,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: const Text(AppTexts.role),
                    subtitle: Text(_roleLabel(role)),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text(AppTexts.editProfile),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            user: widget.user,
                            initialFirstName: firstName,
                            initialLastName: lastName,
                            initialPublicName: publicName,
                            initialPhotoUrl: photoUrl,
                            providerPhotoUrl: providerPhotoUrl,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            if (isRegularUser)
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.discount_outlined),
                      title: const Text(AppTexts.discountStatus),
                      subtitle: Text(
                        '${_discountStatusLabel(discountStatus)}'
                        '${discountStatus == 'approved' ? ' • ${_discountTypeLabel(discountType)}' : ''}'
                        '${discountStatus == 'approved' ? ' • ${AppTexts.validUntil}: ${_formatDiscountDate(discountValidUntil)}' : ''}',
                      ),
                    ),
                    if (canRequestDiscount) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.cardGap),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RequestDiscountScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.discount_outlined),
                            label: const Text(AppTexts.requestDiscount),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            if (canRequestAccountDeletion) ...[
              const SizedBox(height: AppSpacing.cardGap),
              OutlinedButton.icon(
                onPressed: _isDeletingAccount ? null : _requestAccountDeletion,
                icon: const Icon(Icons.delete_forever_outlined),
                label: _isDeletingAccount
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppTexts.deleteAccountRequest),
              ),
            ],
          ],
        );
      },
    );
  }
}
