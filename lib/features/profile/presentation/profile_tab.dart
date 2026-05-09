import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../../auth/data/auth_service.dart';
import '../../../core/constants/app_roles.dart';

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

        final displayName = data?['displayName'] as String?;
        final email = data?['email'] as String?;
        final role = data?['role'] as String?;
        final photoUrl = data?['photoURL'] as String? ?? user.photoURL;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 42,
              child: ClipOval(
                child: photoUrl != null && photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 42);
                        },
                      )
                    : const Icon(Icons.person, size: 42),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                displayName ?? user.displayName ?? AppTexts.profile,
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
