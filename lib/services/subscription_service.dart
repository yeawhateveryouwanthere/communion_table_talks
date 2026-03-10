import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/presentation.dart';

/// Centralized service for determining content access.
///
/// Checks whether the current user can access a given presentation
/// based on: free status, active subscription, or discount code.
class SubscriptionService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check if the current user can access a specific presentation.
  ///
  /// Returns true if:
  /// - The presentation is marked as free (isFree == true)
  /// - The user is authenticated AND has an active subscription
  /// - The user is authenticated AND has an active discount code
  static Future<bool> canAccessPresentation(Presentation presentation) async {
    // Free presentations are always accessible
    if (presentation.isFree) return true;

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Check subscription status in Firestore
    return await hasActiveSubscription(user.uid);
  }

  /// Quick synchronous check — use when you already know the user's status.
  /// For Phase 1, this just checks isFree.
  /// After auth is added, pass in the subscription status.
  static bool canAccessPresentationSync(
    Presentation presentation, {
    bool isSubscribed = false,
  }) {
    if (presentation.isFree) return true;
    return isSubscribed;
  }

  /// Check if a user has an active subscription (paid or via discount code).
  static Future<bool> hasActiveSubscription(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final tier = data['subscriptionTier'] as String?;

      // Free tier has no subscription
      if (tier == null || tier == 'free') {
        // Check for active discount code
        return _hasActiveDiscountCode(data);
      }

      // Check if subscription is still active
      final expiryStr = data['subscriptionExpiry'] as String?;
      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        return DateTime.now().isBefore(expiry);
      }

      return tier == 'monthly' || tier == 'yearly';
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }

  /// Check if a discount code grants active access.
  static bool _hasActiveDiscountCode(Map<String, dynamic> userData) {
    final codeExpiry = userData['discountCodeExpiry'] as String?;
    if (codeExpiry == null) return false;

    final expiry = DateTime.parse(codeExpiry);
    return DateTime.now().isBefore(expiry);
  }

  /// Apply a discount code for the current user.
  /// Returns a result string:
  ///   'success' — code applied
  ///   'not_found' — code doesn't exist or is inactive
  ///   'fully_redeemed' — code has reached its max redemptions
  ///   'error' — unexpected failure
  static Future<String> applyDiscountCode(String uid, String code) async {
    try {
      // Look up the code in Firestore
      final codeQuery = await _db
          .collection('discountCodes')
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (codeQuery.docs.isEmpty) return 'not_found';

      final codeDoc = codeQuery.docs.first;
      final codeRef = codeDoc.reference;

      // Use a transaction to atomically check + increment redemptions
      final result = await _db.runTransaction<String>((transaction) async {
        final freshSnapshot = await transaction.get(codeRef);
        if (!freshSnapshot.exists) return 'not_found';

        final codeData = freshSnapshot.data()!;

        // Check if code is still active
        if (codeData['isActive'] != true) return 'not_found';

        // Check redemption limits
        final maxRedemptions = codeData['maxRedemptions'] as int? ?? 5;
        final timesRedeemed = codeData['timesRedeemed'] as int? ?? 0;

        if (timesRedeemed >= maxRedemptions) return 'fully_redeemed';

        final durationType = codeData['durationType'] as String? ?? 'month';

        // Calculate expiry based on duration type
        DateTime expiry;
        switch (durationType) {
          case 'permanent':
            expiry = DateTime(2099, 12, 31);
            break;
          case 'month':
            expiry = DateTime.now().add(const Duration(days: 30));
            break;
          case 'threeMonths':
            expiry = DateTime.now().add(const Duration(days: 90));
            break;
          case 'year':
            expiry = DateTime.now().add(const Duration(days: 365));
            break;
          default:
            expiry = DateTime.now().add(const Duration(days: 30));
        }

        // Increment the redemption counter on the code
        transaction.update(codeRef, {
          'timesRedeemed': timesRedeemed + 1,
          // Auto-deactivate the code if this was the last redemption
          if (timesRedeemed + 1 >= maxRedemptions) 'isActive': false,
        });

        // Save to user's document
        transaction.set(
          _db.collection('users').doc(uid),
          {
            'discountCodeApplied': code.toUpperCase(),
            'discountCodeExpiry': expiry.toIso8601String(),
            'lastUpdated': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );

        return 'success';
      });

      return result;
    } catch (e) {
      print('Error applying discount code: $e');
      return 'error';
    }
  }
}
