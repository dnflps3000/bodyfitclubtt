import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'public_messages_screen.dart';

class LatestPublicMessageCard extends StatelessWidget {
  const LatestPublicMessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('public_messages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.docs.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('Novinky'),
              subtitle: const Text(
                'Zatiaľ nie sú žiadne správy.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const PublicMessagesScreen(),
                  ),
                );
              },
            ),
          );
        }

        final doc = snapshot.data!.docs.first;

        final data =
            doc.data() as Map<String, dynamic>;

        final authorName =
            data['authorName'] ?? 'Používateľ';

        final text = data['text'] ?? '';

        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.campaign_outlined,
            ),
            title: Text(authorName),
            subtitle: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            isThreeLine: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PublicMessagesScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}