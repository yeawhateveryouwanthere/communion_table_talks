import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/presentation.dart';
import '../models/user_subscription.dart';
import '../services/subscription_service.dart';
import '../services/purchase_service.dart';

/// Provides subscription state to the widget tree via Provider.
///
/// Listens to the user's Firestore document for real-time subscription
/// status updates and integrates with Google Play Billing via PurchaseService.
class SubscriptionProvider extends ChangeNotifier {
  UserSubscription? _subscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;
  String? _currentUid;

  final PurchaseService _purchaseService = PurchaseService();

  UserSubscription? get subscription => _subscription;
  bool get isSubscribed => _subscription?.isSubscribed ?? false;

  /// Whether the Google Play store is available.
  bool get storeAvailable => _purchaseService.storeAvailable;

  /// Whether a purchase is currently being processed.
  bool get purchasePending => _purchaseService.purchasePending;

  /// Error from the last purchase attempt, if any.
  String? get purchaseError => _purchaseService.error;

  /// Product details loaded from the store.
  List get products => _purchaseService.products;

  /// Initialize the purchase service. Call once at app startup.
  Future<void> initializePurchases() async {
    _purchaseService.onStateChanged = () {
      notifyListeners();
    };
    await _purchaseService.initialize();
  }

  /// Start listening to a user's subscription status.
  /// Call this when a user signs in.
  void listenToUser(String uid) {
    // Don't re-subscribe if already listening to same user
    if (_currentUid == uid) return;

    // Cancel any existing subscription
    _firestoreSubscription?.cancel();
    _currentUid = uid;

    _firestoreSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _subscription =
            UserSubscription.fromMap(snapshot.data()!, uid);
      } else {
        _subscription = UserSubscription.free(uid);
      }
      notifyListeners();
    });
  }

  /// Stop listening. Call this when a user signs out.
  void clearUser() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _currentUid = null;
    _subscription = null;
    notifyListeners();
  }

  /// Quick check: can the current user access this presentation?
  bool canAccess(Presentation presentation) {
    return SubscriptionService.canAccessPresentationSync(
      presentation,
      isSubscribed: isSubscribed,
    );
  }

  /// Apply a discount code for the current user.
  /// Returns a result string: 'success', 'not_found', 'fully_redeemed', or 'error'.
  Future<String> applyDiscountCode(String code) async {
    if (_currentUid == null) return 'error';
    return await SubscriptionService.applyDiscountCode(_currentUid!, code);
  }

  /// Buy a subscription plan via Google Play.
  /// [productId] should be kMonthlyProductId or kYearlyProductId.
  Future<bool> buySubscription(String productId) async {
    return await _purchaseService.buySubscription(productId);
  }

  /// Restore previous purchases from Google Play.
  Future<void> restorePurchases() async {
    await _purchaseService.restorePurchases();
  }

  /// Get the display price for a product (from Google Play).
  /// Returns null if the product isn't loaded yet.
  String? getProductPrice(String productId) {
    final product = _purchaseService.getProduct(productId);
    return product?.price;
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _purchaseService.dispose();
    super.dispose();
  }
}
