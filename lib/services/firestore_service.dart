import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/presentation.dart';

/// Handles all Firestore database operations for presentations.
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'presentations';

  /// Fetch all presentations from Firestore.
  static Future<List<Presentation>> getAllPresentations() async {
    final snapshot = await _db
        .collection(_collection)
        .orderBy('datePublished', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Presentation.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Fetch a single presentation by ID.
  static Future<Presentation?> getPresentation(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (doc.exists) {
      return Presentation.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Stream all presentations (updates in real-time).
  static Stream<List<Presentation>> streamPresentations() {
    return _db
        .collection(_collection)
        .orderBy('datePublished', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Presentation.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Ensure all presentations have the isFree field.
  /// Sets isFree to false for any presentations missing the field.
  static Future<void> ensureIsFreeField() async {
    final snapshot = await _db.collection(_collection).get();
    final batch = _db.batch();
    int updated = 0;

    for (final doc in snapshot.docs) {
      if (doc.data()['isFree'] == null) {
        batch.update(doc.reference, {'isFree': false});
        updated++;
      }
    }

    if (updated > 0) {
      await batch.commit();
      print('Updated $updated presentations with isFree field.');
    }
  }

  /// Seed the initial set of free presentations.
  /// Picks 3 brief, 3 medium, and 3 substantive presentations.
  static Future<void> seedFreePresentations() async {
    final snapshot = await _db.collection(_collection).get();
    final docs = snapshot.docs;

    // Check if any are already marked free
    final alreadyFree =
        docs.where((d) => d.data()['isFree'] == true).toList();
    if (alreadyFree.length >= 9) {
      print('Free presentations already seeded.');
      return;
    }

    // Group by length
    final brief = docs.where((d) => d.data()['length'] == 'brief').toList();
    final medium = docs.where((d) => d.data()['length'] == 'medium').toList();
    final substantive =
        docs.where((d) => d.data()['length'] == 'substantive').toList();

    // Pick 3 from each (or fewer if not enough exist)
    final batch = _db.batch();
    int count = 0;
    for (final group in [brief, medium, substantive]) {
      final pickCount = group.length < 3 ? group.length : 3;
      for (int i = 0; i < pickCount; i++) {
        batch.update(group[i].reference, {'isFree': true});
        count++;
      }
    }

    if (count > 0) {
      await batch.commit();
      print('Marked $count presentations as free.');
    }
  }

  /// Create the initial "OrangeView" discount code.
  static Future<void> seedDiscountCodes() async {
    final collection = _db.collection('discountCodes');

    // Check if OrangeView already exists
    final existing = await collection
        .where('code', isEqualTo: 'ORANGEVIEW')
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      print('Discount codes already seeded.');
      return;
    }

    await collection.add({
      'code': 'ORANGEVIEW',
      'durationType': 'year',
      'isActive': true,
      'description': 'OrangeView Church of Christ — 1 year free access',
      'createdAt': DateTime.now().toIso8601String(),
    });

    print('Created OrangeView discount code.');
  }
}
