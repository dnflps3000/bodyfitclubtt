import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../../auth/data/auth_service.dart';
import '../../../core/constants/app_roles.dart';
import 'edit_profile_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.user});

  final User user;

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

  @override
  Widget build(BuildContext context) {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

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
        final photoUrl = data?['photoURL'] as String? ?? user.photoURL;
        final providerPhotoUrl = data?['providerPhotoURL'] as String?;

        final visibleDisplayName = displayName?.isNotEmpty == true
            ? displayName!
            : user.displayName?.isNotEmpty == true
            ? user.displayName!
            : AppTexts.profile;

        return ListView(
          padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            Center(
              child: Text(
                visibleDisplayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text(AppTexts.email),
                    subtitle: Text(
                      email ?? user.email ?? AppTexts.emailNotProvided,
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
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            user: user,
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
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text(AppTexts.settings),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await AuthService().signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text(AppTexts.logoutTooltip),
            ),
          ],
        );
      },
    );
  }
}
