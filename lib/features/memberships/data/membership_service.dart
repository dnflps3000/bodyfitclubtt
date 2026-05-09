import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/membership.dart';
import '../domain/membership_plan.dart';

/* Obsahuje načítanie plánov permanentiek a aktívnych permanentiek používateľa. */
class MembershipService {
  MembershipService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<MembershipPlan>> watchActiveMembershipPlans() {
    return _firestore
        .collection('membershipPlans')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final plans = snapshot.docs
              .map(MembershipPlan.fromFirestore)
              .toList();

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
          final memberships = snapshot.docs.map(Membership.fromFirestore).where(
            (membership) {
              return membership.isValidNow && membership.hasRemainingEntries;
            },
          ).toList();

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
    final now = _startOfToday();
    final validUntil = _validUntilForPlan(plan);

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
      'entriesReserved': plan.entriesTotal == null ? null : 0,
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

  Future<void> createMembershipAfterPayment({
    required MembershipPlan plan,
    required User currentUser,
  }) async {
    final now = _startOfToday();
    final validUntil = _validUntilForPlan(plan);

    final userRef = _firestore.collection('users').doc(currentUser.uid);
    final planRef = _firestore.collection('membershipPlans').doc(plan.id);

    await _firestore.collection('memberships').add({
      'userId': currentUser.uid,
      'userRef': userRef,
      'planId': plan.id,
      'planRef': planRef,
      'planName': plan.name,
      'entriesTotal': plan.entriesTotal,
      'entriesRemaining': plan.entriesTotal,
      'entriesReserved': plan.entriesTotal == null ? null : 0,
      'entriesPerDay': plan.entriesPerDay,
      'validFrom': Timestamp.fromDate(now),
      'validUntil': Timestamp.fromDate(validUntil),
      'status': 'active',
      'paymentStatus': 'paid',
      'price': plan.price,
      'currency': plan.currency,
      'createdBy': currentUser.uid,
      'createdByRef': userRef,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _validUntilForPlan(MembershipPlan plan) {
    final start = _startOfToday();
    final lastValidDay = start.add(Duration(days: plan.validityDays - 1));

    return DateTime(
      lastValidDay.year,
      lastValidDay.month,
      lastValidDay.day,
      23,
      59,
      59,
    );
  }
}
