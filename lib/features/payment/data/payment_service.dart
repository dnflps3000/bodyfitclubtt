import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import '../../memberships/membership_plan.dart';

class PaymentService {
  Future<void> makePayment({
    required MembershipPlan plan,
  }) async {
    try {
      // volanie backendu
      final response = await http.post(
        Uri.parse(
          "https://us-central1-bodyfitclubtt-9acd8.cloudfunctions.net/createPaymentIntent",
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'planId': plan.id,
        }),
      );

      //print("STATUS: ${response.statusCode}");
      //print("BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Backend error: ${response.body}");
      }

      final data = jsonDecode(response.body);
      final clientSecret = data['clientSecret'];

      if (clientSecret == null) {
        throw Exception("Client secret is null");
      }

      //print("INIT PAYMENT SHEET");

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

      //print("PRESENT PAYMENT SHEET");

      await Stripe.instance.presentPaymentSheet();

      //print("PAYMENT SUCCESS");
    } catch (e) {
      //print("PAYMENT ERROR: $e");
      rethrow;
    }
  }
}