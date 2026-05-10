import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_dialog.dart';

class PublicMessagesScreen extends StatelessWidget {
  const PublicMessagesScreen({super.key});

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  bool canManage(String? role) {
    return role == 'trainer' || role == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getCurrentUserData(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data;
        final role = userData?['role'];
        final currentUser = FirebaseAuth.instance.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Novinky'),
          ),
          floatingActionButton: canManage(role)
              ? FloatingActionButton.extended(
                  onPressed: () {
                    showMessageDialog(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Napísať'),
                )
              : null,
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('public_messages')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Zatiaľ nie sú žiadne správy.'),
                );
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final doc = messages[index];

                  final data =
                      doc.data() as Map<String, dynamic>;

                  final authorId = data['authorId'];
                  final authorName =
                      data['authorName'] ?? 'Používateľ';

                  final text = data['text'] ?? '';

                  return Card(
  margin: const EdgeInsets.only(bottom: 8),
  child: Padding(
    padding: const EdgeInsets.only(
      left: 14,
      right: 6,
      top: 8,
      bottom: 10,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (currentUser != null &&
                (currentUser.uid == authorId || role == 'admin') &&
                canManage(role))
              SizedBox(
                width: 36,
                height: 32,
                child: PopupMenuButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Upraviť'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Vymazať'),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      showMessageDialog(
                        context,
                        docId: doc.id,
                        oldText: text,
                      );
                    }

                    if (value == 'delete') {
                      await FirebaseFirestore.instance
                          .collection('public_messages')
                          .doc(doc.id)
                          .delete();
                    }
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
);
                },
              );
            },
          ),
        );
      },
    );
  }
}