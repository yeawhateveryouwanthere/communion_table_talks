import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/presentation.dart';
import '../models/user_subscription.dart';
import '../services/subscription_service.dart';

/// Provides subscription state to the widget tree via Provider.
///
/// Listens to the user's Firestore document for real-time subscription
/// status updates and notifies the UI when access changes.
class SubscriptionProvider extends ChangeNotifier {
  UserSubscription? _subscription;
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;
  String? _currentUid;

  UserSubscription? get subscription => _subscription;
  bool get isSubscribed => _subscription?.isSubscribed ?? false;

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

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
