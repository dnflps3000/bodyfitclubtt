import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import '../../memberships/domain/membership_plan.dart';

class PaymentResult {
  const PaymentResult({required this.paymentIntentId});

  final String paymentIntentId;
}

class PaymentService {
  Future<PaymentResult> makePayment({required MembershipPlan plan}) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://europe-west1-bodyfitclubtt-9acd8.cloudfunctions.net/createPaymentIntent',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'planId': plan.id}),
      );

      if (response.statusCode != 200) {
        throw Exception('Backend error: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final clientSecret = data['clientSecret'] as String?;
      final paymentIntentId = data['paymentIntentId'] as String? ?? '';

      if (clientSecret == null) {
        throw Exception('Client secret is null');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'BodyFitClub',
          style: ThemeMode.system,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'SK',
            currencyCode: 'EUR',
            testEnv: true,
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentResult(paymentIntentId: paymentIntentId);
    } catch (_) {
      rethrow;
    }
  }
}
