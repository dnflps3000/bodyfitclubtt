import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'membership.dart';
import 'membership_plan.dart';

/* Obsahuje načítanie plánov permanentiek a aktívnych permanentiek používateľa. */
class MembershipService {
  MembershipService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<MembershipPlan>> watchActiveMembershipPlans() {
    return _firestore
        .collection('membershipPlans')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final plans = snapshot.docs.map(MembershipPlan.fromFirestore).toList();

      plans.sort((a, b) => a.price.compareTo(b.price));

      return plans;
    });
  }

  Stream<List<Membership>> watchMyActiveMemberships() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('memberships')
        .where('userId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final memberships =
          snapshot.docs.map(Membership.fromFirestore).where((membership) {
        return membership.isValidNow && membership.hasRemainingEntries;
      }).toList();

      memberships.sort((a, b) {
        final firstValidUntil = a.validUntil;
        final secondValidUntil = b.validUntil;

        if (firstValidUntil == null && secondValidUntil == null) {
          return 0;
        }

        if (firstValidUntil == null) {
          return 1;
        }

        if (secondValidUntil == null) {
          return -1;
        }

        return firstValidUntil.compareTo(secondValidUntil);
      });

      return memberships;
    });
  }

  Future<void> assignMembershipToUser({
    required MembershipPlan plan,
    required String userId,
    required User currentUser,
  }) async {
    final now = DateTime.now();
    final validUntil = now.add(Duration(days: plan.validityDays));

    final userRef = _firestore.collection('users').doc(userId);
    final planRef = _firestore.collection('membershipPlans').doc(plan.id);
    final createdByRef = _firestore.collection('users').doc(currentUser.uid);

    await _firestore.collection('memberships').add({
      'userId': userId,
      'userRef': userRef,
      'planId': plan.id,
      'planRef': planRef,
      'planName': plan.name,
      'entriesTotal': plan.entriesTotal,
      'entriesRemaining': plan.entriesTotal,
      'entriesPerDay': plan.entriesPerDay,
      'validFrom': Timestamp.fromDate(now),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': 'active',
      'paymentStatus': 'manual',
      'price': plan.price,
      'currency': plan.currency,
      'createdBy': currentUser.uid,
      'createdByRef': createdByRef,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}