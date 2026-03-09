/// Represents a single Lord's Supper presentation.
///
/// Each presentation has a title, scripture passage, body text,
/// summary, topic tags, length category, and suggested hymns.

enum PresentationLength {
  brief,
  medium,
  substantive,
}

class Presentation {
  final String id;
  final String title;
  final String scripturePassage;
  final String bodyText; // Rich text stored as HTML
  final String summary;
  final List<String> topicTags;
  final PresentationLength length;
  final List<String> suggestedHymns;
  final DateTime datePublished;
  final bool isFree;

  Presentation({
    required this.id,
    required this.title,
    required this.scripturePassage,
    required this.bodyText,
    required this.summary,
    required this.topicTags,
    required this.length,
    required this.suggestedHymns,
    required this.datePublished,
    this.isFree = false,
  });

  /// Human-readable label for the length category.
  String get lengthLabel {
    switch (length) {
      case PresentationLength.brief:
        return 'Brief';
      case PresentationLength.medium:
        return 'Medium';
      case PresentationLength.substantive:
        return 'Substantive';
    }
  }

  /// Creates a Presentation from a Firestore document map.
  factory Presentation.fromMap(Map<String, dynamic> map, String documentId) {
    return Presentation(
      id: documentId,
      title: map['title'] ?? '',
      scripturePassage: map['scripturePassage'] ?? '',
      bodyText: map['bodyText'] ?? '',
      summary: map['summary'] ?? '',
      topicTags: List<String>.from(map['topicTags'] ?? []),
      length: PresentationLength.values.firstWhere(
        (e) => e.name == map['length'],
        orElse: () => PresentationLength.medium,
      ),
      suggestedHymns: List<String>.from(map['suggestedHymns'] ?? []),
      datePublished: map['datePublished'] != null
          ? DateTime.parse(map['datePublished'])
          : DateTime.now(),
      isFree: map['isFree'] ?? false,
    );
  }

  /// Converts this Presentation to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'scripturePassage': scripturePassage,
      'bodyText': bodyText,
      'summary': summary,
      'topicTags': topicTags,
      'length': length.name,
      'suggestedHymns': suggestedHymns,
      'datePublished': datePublished.toIso8601String(),
      'isFree': isFree,
    };
  }
}
