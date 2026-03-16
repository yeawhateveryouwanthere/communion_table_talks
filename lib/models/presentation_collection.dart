import 'package:flutter/material.dart';

/// A curated collection of presentations organized by season or topic.
///
/// Collections filter presentations by matching against topic tags,
/// making the browsing experience feel like a thoughtfully organized
/// bookshelf rather than a database.
class PresentationCollection {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> matchTags;

  /// Optional: specific months when this collection is most relevant.
  /// Used to highlight seasonal collections at the right time of year.
  final List<int>? seasonalMonths;

  const PresentationCollection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.matchTags,
    this.seasonalMonths,
  });

  /// Whether this collection is currently "in season" based on the date.
  bool get isInSeason {
    if (seasonalMonths == null) return false;
    return seasonalMonths!.contains(DateTime.now().month);
  }
}
