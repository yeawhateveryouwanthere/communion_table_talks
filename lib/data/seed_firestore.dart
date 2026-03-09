import 'package:cloud_firestore/cloud_firestore.dart';
import 'sample_presentations.dart';

/// Seeds Firestore with sample presentation data.
///
/// Call this once to populate the database, then remove or disable it.
Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final collection = db.collection('presentations');

  // Check if data already exists
  final existing = await collection.limit(1).get();
  if (existing.docs.isNotEmpty) {
    print('Firestore already has presentations. Skipping seed.');
    return;
  }

  print('Seeding Firestore with sample presentations...');

  for (final presentation in samplePresentations) {
    await collection.add(presentation.toMap());
    print('  Added: ${presentation.title}');
  }

  print('Done! Added ${samplePresentations.length} presentations.');
}
