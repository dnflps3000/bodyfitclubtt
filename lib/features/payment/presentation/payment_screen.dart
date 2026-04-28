import 'package:flutter/material.dart';
import '../data/payment_service.dart';

// 🔥 PRIDAJ IMPORTY
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Platba")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await PaymentService().makePayment();

              // 🔥 ULOŽENIE DO FIREBASE
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .set({
                'membership': 'active',
                'remainingEntries': 10,
                'lastPayment': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Platba úspešná")),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Platba zlyhala")),
              );
            }
          },
          child: const Text("Zaplatiť 9.99€"),
        ),
      ),
    );
  }
}