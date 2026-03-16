import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/subscription_provider.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/discount_code_dialog.dart';
import 'auth_screen.dart';

/// Full-page subscription management screen.
///
/// Shows current subscription status, plan options, and discount code entry.
/// Accessible from the About screen and paywall.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final subProvider = context.watch<SubscriptionProvider>();
    final isSubscribed = subProvider.isSubscribed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isSubscribed
                    ? LinearGradient(
                        colors: [
                          Colors.green.shade600,
                          Colors.green.shade800,
                        ],
                      )
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    isSubscribed ? Icons.star : Icons.star_border,
                    size: 44,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSubscribed ? 'You\'re Subscribed!' : 'Free Plan',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSubscribed
                        ? 'All presentations are unlocked.'
                        : '9 free presentations available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  if (subProvider.subscription?.discountCodeApplied != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Code: ${subProvider.subscription!.discountCodeApplied}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Plan options (only show if not subscribed)
            if (!isSubscribed) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose a Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Show loading indicator during purchase
              if (subProvider.purchasePending) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Processing purchase...'),
                    ],
                  ),
                ),
              ] else ...[
                // Monthly — use real price from Google Play if available
                _buildPlanCard(
                  context,
                  title: 'Monthly',
                  price: '${subProvider.getProductPrice(kMonthlyProductId) ?? '\$4.99'}/month',
                  description: 'Cancel anytime. Full access to all presentations.',
                  icon: Icons.calendar_today,
                  onTap: () => _handlePurchase(context, kMonthlyProductId, authProvider, subProvider),
                ),

                const SizedBox(height: 12),

                // Yearly — use real price from Google Play if available
                _buildPlanCard(
                  context,
                  title: 'Yearly',
                  price: '${subProvider.getProductPrice(kYearlyProductId) ?? '\$49.99'}/year',
                  description: 'Save 17% — best value for regular use.',
                  icon: Icons.calendar_month,
                  isRecommended: true,
                  onTap: () => _handlePurchase(context, kYearlyProductId, authProvider, subProvider),
                ),
              ],

              const SizedBox(height: 16),

              // Restore purchases link
              TextButton(
                onPressed: () => subProvider.restorePurchases(),
                child: Text(
                  'Restore Previous Purchase',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.dividerColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.dividerColor)),
                ],
              ),

              const SizedBox(height: 24),
            ],

            // Discount code section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 32,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Have a Discount Code?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter a code from your church or event to unlock all content.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => DiscountCodeDialog.show(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                            color: AppTheme.primaryColor.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: Icon(Icons.vpn_key_outlined,
                          size: 18, color: AppTheme.primaryColor),
                      label: Text(
                        'Enter Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sign-in prompt
            if (!authProvider.isSignedIn) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: AppTheme.accentDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sign in to subscribe or use a discount code.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AuthScreen()),
                        );
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required IconData icon,
    bool isRecommended = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRecommended
                ? AppTheme.primaryColor.withOpacity(0.3)
                : AppTheme.dividerColor,
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(
    BuildContext context,
    String productId,
    app_auth.AuthProvider authProvider,
    SubscriptionProvider subProvider,
  ) async {
    if (!authProvider.isSignedIn) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      return;
    }

    if (!context.mounted) return;

    // Check if store is available
    if (!subProvider.storeAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'In-app purchases are not available on this device. Try a discount code instead!',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }

    // Initiate the purchase — Google Play handles the UI from here
    final success = await subProvider.buySubscription(productId);

    if (!success && context.mounted) {
      final error = subProvider.purchaseError;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
