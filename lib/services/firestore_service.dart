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
}
