import 'package:shared_preferences/shared_preferences.dart';
import '../models/scheduled_presentation.dart';

/// Handles local storage of scheduled presentations.
///
/// Uses SharedPreferences to persist data between app sessions.
class StorageService {
  static const String _scheduledKey = 'scheduled_presentations';

  /// Load all scheduled presentations from local storage.
  static Future<List<ScheduledPresentation>> loadScheduledPresentations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_scheduledKey) ?? [];
    return jsonList.map((json) => ScheduledPresentation.fromJson(json)).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  /// Save a scheduled presentation to local storage.
  static Future<void> saveScheduledPresentation(
      ScheduledPresentation scheduled) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_scheduledKey) ?? [];

    // Remove any existing entry for the same date
    final dateString = _dateToString(scheduled.scheduledDate);
    jsonList.removeWhere((json) {
      final existing = ScheduledPresentation.fromJson(json);
      return _dateToString(existing.scheduledDate) == dateString;
    });

    // Add the new entry
    jsonList.add(scheduled.toJson());

    await prefs.setStringList(_scheduledKey, jsonList);
  }

  /// Remove a scheduled presentation by date.
  static Future<void> removeScheduledPresentation(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_scheduledKey) ?? [];
    final dateString = _dateToString(date);

    jsonList.removeWhere((json) {
      final existing = ScheduledPresentation.fromJson(json);
      return _dateToString(existing.scheduledDate) == dateString;
    });

    await prefs.setStringList(_scheduledKey, jsonList);
  }

  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
