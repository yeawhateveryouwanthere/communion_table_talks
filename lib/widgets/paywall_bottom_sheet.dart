import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/subscription_provider.dart';
import '../screens/auth_screen.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';
import 'discount_code_dialog.dart';

/// A bottom sheet that presents subscription options and discount code entry.
///
/// Shows the two subscription tiers ($5/month, $49/year) and a link
/// to enter a discount code. Connects to Google Play Billing for purchases.
class PaywallBottomSheet extends StatelessWidget {
  const PaywallBottomSheet({super.key});

  /// Show the paywall. Returns true if the user successfully subscribed.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PaywallBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final subProvider = context.watch<SubscriptionProvider>();

    // Get real prices from Google Play if available
    final monthlyPrice = subProvider.getProductPrice(kMonthlyProductId) ?? '\$4.99';
    final yearlyPrice = subProvider.getProductPrice(kYearlyProductId) ?? '\$49.99';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Lock icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              size: 28,
              color: AppTheme.accentDark,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Unlock All Presentations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Get access to every presentation in the library, including new ones added each month.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Loading indicator when purchase is processing
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
            // Subscription options
            _buildPlanOption(
              context,
              title: 'Monthly',
              price: monthlyPrice,
              period: '/month',
              isPopular: false,
              onTap: () => _handleSubscribe(context, kMonthlyProductId, authProvider, subProvider),
            ),

            const SizedBox(height: 12),

            _buildPlanOption(
              context,
              title: 'Yearly',
              price: yearlyPrice,
              period: '/year',
              savings: 'Save 17%',
              isPopular: true,
              onTap: () => _handleSubscribe(context, kYearlyProductId, authProvider, subProvider),
            ),
          ],

          const SizedBox(height: 20),

          // Discount code link
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context); // Close the bottom sheet
              await DiscountCodeDialog.show(context);
            },
            icon: Icon(
              Icons.confirmation_number_outlined,
              size: 18,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),
            label: Text(
              'Have a discount code?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor.withOpacity(0.6),
              ),
            ),
          ),

          // Sign-in prompt if not signed in
          if (!authProvider.isSignedIn) ...[
            const SizedBox(height: 4),
            Text(
              'You\'ll need to sign in to subscribe.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withOpacity(0.6),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPlanOption(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? savings,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPopular
              ? AppTheme.primaryColor.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPopular
                ? AppTheme.primaryColor.withOpacity(0.3)
                : AppTheme.dividerColor,
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Plan info
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
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Best Value',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (savings != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      savings,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.textSecondary.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscribe(
    BuildContext context,
    String productId,
    app_auth.AuthProvider authProvider,
    SubscriptionProvider subProvider,
  ) async {
    if (!authProvider.isSignedIn) {
      // Need to sign in first
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (result != true) return;
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
