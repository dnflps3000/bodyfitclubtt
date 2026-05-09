import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../../memberships/domain/membership_plan.dart';
import '../../memberships/data/membership_service.dart';
import '../data/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.purchaseCategory,
    this.preselectedPlanId,
  });

  final String? purchaseCategory;
  final String? preselectedPlanId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final MembershipService _membershipService = MembershipService();
  final PaymentService _paymentService = PaymentService();

  MembershipPlan? _selectedPlan;
  bool _isPaying = false;

  String _formatPrice(MembershipPlan plan) {
    return '${plan.price.toStringAsFixed(2)} ${plan.currency}';
  }

  Future<void> _payForSelectedPlan() async {
    final selectedPlan = _selectedPlan;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (selectedPlan == null || currentUser == null) {
      return;
    }

    setState(() {
      _isPaying = true;
    });

    try {
      await _paymentService.makePayment(plan: selectedPlan);

      await _membershipService.createMembershipAfterPayment(
        plan: selectedPlan,
        currentUser: currentUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.paymentSuccessful)));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.paymentFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.payment)),

      // Obsah obrazovky - iba zoznam permanentiek/vstupov.
      body: StreamBuilder<List<MembershipPlan>>(
        stream: _membershipService.watchActiveMembershipPlans(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text(AppTexts.membershipPlansLoadError));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allPlans = snapshot.data!;

          final plans = widget.purchaseCategory == null
              ? allPlans
              : allPlans
                    .where(
                      (plan) =>
                          plan.purchaseCategory == widget.purchaseCategory,
                    )
                    .toList();

          if (plans.isEmpty) {
            return const Center(child: Text(AppTexts.membershipPlansLoadError));
          }

          final initialSelectedPlan = widget.preselectedPlanId == null
              ? plans.first
              : plans.firstWhere(
                  (plan) => plan.id == widget.preselectedPlanId,
                  orElse: () => plans.first,
                );

          if (_selectedPlan == null ||
              !plans.any((plan) => plan.id == _selectedPlan!.id)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              setState(() {
                _selectedPlan = initialSelectedPlan;
              });
            });
          }

          final displayedSelectedPlan = _selectedPlan ?? initialSelectedPlan;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                AppTexts.chooseMembership,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              for (final plan in plans)
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isPaying
                        ? null
                        : () {
                            setState(() {
                              _selectedPlan = plan;
                            });
                          },
                    child: ListTile(
                      leading: Icon(
                        displayedSelectedPlan.id == plan.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(plan.name),
                      subtitle: Text(plan.description),
                      trailing: Text(
                        _formatPrice(plan),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      // Tlačidlo je mimo ListView a SafeArea ho drží nad systémovou lištou.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _selectedPlan == null || _isPaying
              ? null
              : _payForSelectedPlan,
          child: _isPaying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _selectedPlan == null
                      ? AppTexts.pay
                      : '${AppTexts.pay} ${_formatPrice(_selectedPlan!)}',
                ),
        ),
      ),
    );
  }
}
