import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showMessageDialog(
  BuildContext context, {
  String? docId,
  String? oldText,
}) {
  final controller = TextEditingController(text: oldText ?? '');
  final user = FirebaseAuth.instance.currentUser;

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(docId == null ? 'Napísať správu' : 'Upraviť správu'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Napíš správu...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrušiť'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();

              if (text.isEmpty || user == null) return;

              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();

              final userData = userDoc.data();

              final role = userData?['role'];

              final baseName =
                userData?['publicName'] ??
                userData?['displayName'] ??
                user.displayName ??
                'Používateľ';
              String publicName = baseName;
              if (role == 'trainer') {
                publicName = 'Tréner - $baseName';
              }
              if (role == 'admin') {
                publicName = 'Admin - $baseName';
              }
              if (role != 'trainer' && role != 'admin') return;
              
              if (docId == null) {
                await FirebaseFirestore.instance.collection('public_messages').add({
                  'text': text,
                  'authorId': user.uid,
                  'authorName': publicName,
                  'authorRole': role,
                  'createdAt': FieldValue.serverTimestamp(),
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              } else {
                await FirebaseFirestore.instance
                    .collection('public_messages')
                    .doc(docId)
                    .update({
                  'text': text,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Uložiť'),
          ),
        ],
      );
    },
  );
}