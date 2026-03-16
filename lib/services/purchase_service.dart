import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Product IDs — must match exactly what's in Google Play Console.
const String kMonthlyProductId = 'monthly_premium';
const String kYearlyProductId = 'yearly_premium';
const Set<String> kProductIds = {kMonthlyProductId, kYearlyProductId};

/// Handles all Google Play Billing interactions via in_app_purchase.
///
/// This is a singleton service that:
/// - Checks store availability
/// - Loads product details (prices, descriptions)
/// - Initiates subscription purchases
/// - Listens for purchase updates
/// - Verifies completed purchases and updates Firestore
/// - Restores previous purchases
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Whether the store is available on this device.
  bool _storeAvailable = false;
  bool get storeAvailable => _storeAvailable;

  /// Loaded product details from the store.
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  /// Whether we're currently processing a purchase.
  bool _purchasePending = false;
  bool get purchasePending => _purchasePending;

  /// Error message from the last failed operation.
  String? _error;
  String? get error => _error;

  /// Callback to notify the UI of state changes.
  VoidCallback? onStateChanged;

  /// Initialize the purchase service. Call once at app startup.
  Future<void> initialize() async {
    _storeAvailable = await _iap.isAvailable();

    if (!_storeAvailable) {
      print('PurchaseService: Store not available on this device.');
      return;
    }

    // Start listening to purchase updates
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) {
        print('PurchaseService: Purchase stream error: $error');
      },
    );

    // Load product details from the store
    await loadProducts();
  }

  /// Load available products from Google Play.
  Future<void> loadProducts() async {
    if (!_storeAvailable) return;

    try {
      final response = await _iap.queryProductDetails(kProductIds);

      if (response.error != null) {
        print('PurchaseService: Error loading products: ${response.error}');
        _error = 'Could not load subscription options.';
        onStateChanged?.call();
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('PurchaseService: Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      _error = null;
      onStateChanged?.call();
    } catch (e) {
      print('PurchaseService: Exception loading products: $e');
      _error = 'Could not connect to the store.';
      onStateChanged?.call();
    }
  }

  /// Get the ProductDetails for a specific product, if loaded.
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Initiate a subscription purchase.
  Future<bool> buySubscription(String productId) async {
    final product = getProduct(productId);
    if (product == null) {
      _error = 'Product not available. Please try again later.';
      onStateChanged?.call();
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'Please sign in before subscribing.';
      onStateChanged?.call();
      return false;
    }

    try {
      _purchasePending = true;
      _error = null;
      onStateChanged?.call();

      final purchaseParam = PurchaseParam(productDetails: product);
      // buyNonConsumable is used for subscriptions in the in_app_purchase plugin
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      if (!success) {
        _purchasePending = false;
        _error = 'Could not initiate purchase. Please try again.';
        onStateChanged?.call();
        return false;
      }

      return true;
    } catch (e) {
      print('PurchaseService: Error initiating purchase: $e');
      _purchasePending = false;
      _error = 'Something went wrong. Please try again.';
      onStateChanged?.call();
      return false;
    }
  }

  /// Restore previous purchases (e.g., after reinstall).
  Future<void> restorePurchases() async {
    if (!_storeAvailable) return;

    try {
      _purchasePending = true;
      _error = null;
      onStateChanged?.call();

      await _iap.restorePurchases();
    } catch (e) {
      print('PurchaseService: Error restoring purchases: $e');
      _purchasePending = false;
      _error = 'Could not restore purchases. Please try again.';
      onStateChanged?.call();
    }
  }

  /// Handle purchase updates from the store.
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _handlePurchase(purchase);
    }
  }

  /// Process an individual purchase update.
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        _purchasePending = true;
        _error = null;
        onStateChanged?.call();
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Verify and deliver the purchase
        final verified = await _verifyAndDeliverPurchase(purchase);
        if (!verified) {
          _error = 'Purchase could not be verified. Please contact support.';
        }
        _purchasePending = false;
        onStateChanged?.call();

        // Complete the purchase with the store
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;

      case PurchaseStatus.error:
        _purchasePending = false;
        _error = purchase.error?.message ?? 'Purchase failed. Please try again.';
        onStateChanged?.call();

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;

      case PurchaseStatus.canceled:
        _purchasePending = false;
        _error = null; // User intentionally cancelled — no error message
        onStateChanged?.call();

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        break;
    }
  }

  /// Verify a purchase and update the user's subscription in Firestore.
  ///
  /// In a production app, you'd verify the purchase receipt server-side.
  /// For now, we trust the client-side verification from Google Play.
  Future<bool> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('PurchaseService: No authenticated user for purchase delivery.');
        return false;
      }

      // Determine the tier based on product ID
      String tier;
      int durationDays;
      if (purchase.productID == kMonthlyProductId) {
        tier = 'monthly';
        durationDays = 30;
      } else if (purchase.productID == kYearlyProductId) {
        tier = 'yearly';
        durationDays = 365;
      } else {
        print('PurchaseService: Unknown product ID: ${purchase.productID}');
        return false;
      }

      // Calculate subscription expiry
      final expiry = DateTime.now().add(Duration(days: durationDays));

      // Update Firestore
      await _db.collection('users').doc(user.uid).set({
        'subscriptionTier': tier,
        'subscriptionExpiry': expiry.toIso8601String(),
        'purchaseToken': purchase.purchaseID,
        'lastUpdated': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      print('PurchaseService: Subscription activated — $tier until $expiry');
      return true;
    } catch (e) {
      print('PurchaseService: Error delivering purchase: $e');
      return false;
    }
  }

  /// Clean up resources.
  void dispose() {
    _purchaseSubscription?.cancel();
  }
}
