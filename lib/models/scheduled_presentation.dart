import 'dart:convert';

/// Represents a presentation that has been scheduled for a specific date.
class ScheduledPresentation {
  final String presentationId;
  final String presentationTitle;
  final String scripturePassage;
  final String lengthLabel;
  final DateTime scheduledDate;

  ScheduledPresentation({
    required this.presentationId,
    required this.presentationTitle,
    required this.scripturePassage,
    required this.lengthLabel,
    required this.scheduledDate,
  });

  factory ScheduledPresentation.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ScheduledPresentation(
      presentationId: map['presentationId'],
      presentationTitle: map['presentationTitle'],
      scripturePassage: map['scripturePassage'],
      lengthLabel: map['lengthLabel'],
      scheduledDate: DateTime.parse(map['scheduledDate']),
    );
  }

  String toJson() {
    return jsonEncode({
      'presentationId': presentationId,
      'presentationTitle': presentationTitle,
      'scripturePassage': scripturePassage,
      'lengthLabel': lengthLabel,
      'scheduledDate': scheduledDate.toIso8601String(),
    });
  }
}
