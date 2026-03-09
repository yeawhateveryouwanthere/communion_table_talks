/// Represents a user's subscription status in Firestore.
class UserSubscription {
  final String uid;
  final String subscriptionTier; // 'free', 'monthly', 'yearly'
  final DateTime? subscriptionExpiry;
  final String? discountCodeApplied;
  final DateTime? discountCodeExpiry;
  final DateTime lastUpdated;

  UserSubscription({
    required this.uid,
    this.subscriptionTier = 'free',
    this.subscriptionExpiry,
    this.discountCodeApplied,
    this.discountCodeExpiry,
    required this.lastUpdated,
  });

  bool get isSubscribed {
    if (subscriptionTier == 'monthly' || subscriptionTier == 'yearly') {
      if (subscriptionExpiry != null) {
        return DateTime.now().isBefore(subscriptionExpiry!);
      }
      return true;
    }
    // Check discount code
    if (discountCodeExpiry != null) {
      return DateTime.now().isBefore(discountCodeExpiry!);
    }
    return false;
  }

  factory UserSubscription.free(String uid) {
    return UserSubscription(
      uid: uid,
      subscriptionTier: 'free',
      lastUpdated: DateTime.now(),
    );
  }

  factory UserSubscription.fromMap(Map<String, dynamic> map, String uid) {
    return UserSubscription(
      uid: uid,
      subscriptionTier: map['subscriptionTier'] ?? 'free',
      subscriptionExpiry: map['subscriptionExpiry'] != null
          ? DateTime.parse(map['subscriptionExpiry'])
          : null,
      discountCodeApplied: map['discountCodeApplied'],
      discountCodeExpiry: map['discountCodeExpiry'] != null
          ? DateTime.parse(map['discountCodeExpiry'])
          : null,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subscriptionTier': subscriptionTier,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'discountCodeApplied': discountCodeApplied,
      'discountCodeExpiry': discountCodeExpiry?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
