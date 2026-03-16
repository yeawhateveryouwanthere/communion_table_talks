import 'package:flutter/material.dart';
import '../models/presentation_collection.dart';

/// Curated collections of presentations organized by season and topic.
///
/// Each collection matches presentations by their topic tags, so
/// presentations can appear in multiple collections when relevant.
const List<PresentationCollection> seasonalCollections = [
  // ── Seasonal Collections ──────────────────────────────────────────

  PresentationCollection(
    id: 'birth_of_jesus',
    title: 'Birth of Jesus',
    subtitle: 'The Incarnation & God With Us',
    description:
        'Presentations celebrating the miracle of God becoming flesh — '
        'the eternal Word made man, born to save.',
    icon: Icons.child_care,
    color: Color(0xFF2E7D32), // Deep green
    matchTags: [
      'Christmas',
      'Incarnation',
      'incarnation',
      'Only Begotten Son',
      'Father\'s Love',
      'Love of God',
      'love of God',
      'Gift of God',
      'gift',
    ],
    seasonalMonths: [11, 12, 1], // Nov–Jan
  ),

  PresentationCollection(
    id: 'death_resurrection',
    title: 'Death & Resurrection',
    subtitle: 'The Cross & the Empty Tomb',
    description:
        'Presentations focused on the suffering, death, and triumphant '
        'resurrection of Jesus — the heart of the gospel.',
    icon: Icons.brightness_7,
    color: Color(0xFF6B2D3E), // Burgundy
    matchTags: [
      'cross',
      'The Cross',
      'resurrection',
      'cross and resurrection',
      'Calvary',
      'Gethsemane',
      'Trial of Jesus',
      'trial of Jesus',
      'Words from the Cross',
      'words from the cross',
      'seven last words',
      'Two Thieves',
      'Simon of Cyrene',
      'Silence of Christ',
      'agony',
      'Passover',
      'Power of the Cross',
      'power of the cross',
      'darkness',
      'forsakenness',
      'suffering',
      'Crucifixion',
      'scars',
    ],
    seasonalMonths: [3, 4], // March–April
  ),

  PresentationCollection(
    id: 'thanksgiving',
    title: 'Gratitude & Thanksgiving',
    subtitle: 'A Grateful Heart at the Table',
    description:
        'Presentations that center on thankfulness — for the sacrifice, '
        'for grace, and for the blessings God has given.',
    icon: Icons.volunteer_activism,
    color: Color(0xFFE65100), // Deep orange
    matchTags: [
      'Thanksgiving',
      'Gratitude',
      'Praise',
      'praise',
      'Worship',
      'worship',
      'grace',
      'Grace',
      'gift',
      'Gift of God',
    ],
    seasonalMonths: [10, 11], // Oct–Nov
  ),

  PresentationCollection(
    id: 'memorial_sacrifice',
    title: 'Sacrifice & Service',
    subtitle: 'Honoring Those Who Gave All',
    description:
        'Presentations about sacrifice, laying down one\'s life, and the '
        'ultimate sacrifice of Christ — fitting for times of national remembrance.',
    icon: Icons.flag,
    color: Color(0xFF1565C0), // Deep blue
    matchTags: [
      'Sacrifice',
      'sacrifice',
      'laying down life',
      'Willing Sacrifice',
      'Substitution',
      'substitution',
      'Substitutionary Atonement',
      'Cost of Redemption',
      'Cost of Salvation',
      'offering',
      'Surrender',
      'surrender',
      'Freedom',
      'freedom',
      'Deliverance',
      'deliverance',
    ],
    seasonalMonths: [5, 7], // May (Memorial Day) & July (4th)
  ),

  PresentationCollection(
    id: 'new_year',
    title: 'New Beginnings',
    subtitle: 'New Year, New Creation',
    description:
        'Presentations about renewal, new life in Christ, and fresh '
        'starts — perfect for the start of a new year.',
    icon: Icons.auto_awesome,
    color: Color(0xFF6A1B9A), // Deep purple
    matchTags: [
      'New Year',
      'New Beginnings',
      'New Creation',
      'new creation',
      'new life',
      'new birth',
      'New Beginnings',
      'new covenant',
      'Hope',
      'hope',
      'restoration',
    ],
    seasonalMonths: [12, 1], // Dec–Jan
  ),
];

const List<PresentationCollection> topicalCollections = [
  // ── Topical Collections ───────────────────────────────────────────

  PresentationCollection(
    id: 'blood_covenant',
    title: 'The Blood of the Covenant',
    subtitle: 'The Crimson Thread of Scripture',
    description:
        'From Abel\'s offering to the cross, trace the scarlet thread of '
        'blood sacrifice that runs through all of Scripture.',
    icon: Icons.water_drop,
    color: Color(0xFFC62828), // Deep red
    matchTags: [
      'Blood of Christ',
      'blood of Christ',
      'blood',
      'blood sacrifice',
      'Precious Blood',
      'crimson thread',
      'Atonement',
      'Day of Atonement',
      'Propitiation',
      'propitiation',
      'mercy seat',
      'covering',
      'Abel',
      'Lamb of God',
      'lamb',
      'redemption thread',
    ],
  ),

  PresentationCollection(
    id: 'grace_mercy',
    title: 'Grace at the Table',
    subtitle: 'Unmerited Favor & Divine Mercy',
    description:
        'Presentations that remind us we don\'t come to this table because '
        'we earned a seat — we come because grace pulled out the chair.',
    icon: Icons.favorite,
    color: Color(0xFFAD1457), // Deep pink
    matchTags: [
      'Grace',
      'grace',
      'Grace vs. Works',
      'Mercy',
      'mercy',
      'Forgiveness',
      'forgiveness',
      'unmerited',
      'Imputed Righteousness',
      'while we were sinners',
      'justification',
      'peace with God',
    ],
  ),

  PresentationCollection(
    id: 'old_testament_shadows',
    title: 'Shadows & Types',
    subtitle: 'Old Testament Pictures of the Cross',
    description:
        'The Passover lamb, Abraham and Isaac, the Day of Atonement — '
        'how the Old Testament pointed forward to Christ\'s sacrifice.',
    icon: Icons.auto_stories,
    color: Color(0xFF4E342E), // Brown
    matchTags: [
      'Passover',
      'Abraham and Isaac',
      'Day of Atonement',
      'Typology',
      'Exodus',
      'Isaiah 53',
      'Psalm 22',
      'Psalm 23',
      'Genesis',
      'Zechariah',
      'Jeremiah',
      'Prophecy Fulfilled',
      'prophecy',
      'fulfillment',
      'Lord\'s Supper origin',
      'altar',
      'temple',
    ],
  ),

  PresentationCollection(
    id: 'comfort_grief',
    title: 'When the Church Is Grieving',
    subtitle: 'Comfort in Times of Loss',
    description:
        'For those Sundays when the congregation carries a heavy heart. '
        'Presentations that bring comfort, hope, and the nearness of God.',
    icon: Icons.healing,
    color: Color(0xFF37474F), // Blue grey
    matchTags: [
      'comfort',
      'Hope',
      'hope',
      'grief',
      'nearness of God',
      'God\'s presence',
      'never alone',
      'Anchor',
      'anchor',
      'Rest',
      'peace',
      'Good Shepherd',
      'shepherd',
      'Psalm 23',
      'eternal life',
      'heaven',
      'Assurance',
      'assurance',
    ],
  ),

  PresentationCollection(
    id: 'remembrance_purpose',
    title: 'Why We Do This',
    subtitle: 'The Purpose of the Lord\'s Supper',
    description:
        'Getting back to basics — why do we gather around this table '
        'every first day of the week? What did Jesus intend?',
    icon: Icons.lightbulb_outline,
    color: Color(0xFFF57F17), // Amber
    matchTags: [
      'Remembrance',
      'remembrance',
      'Purpose of the Lords Supper',
      'Weekly Observance',
      'institution',
      'institution of the supper',
      'Last Supper',
      'communion',
      'proclamation',
      '1 Corinthians 11',
      'Luke 22',
      'broken bread',
      'body of Christ',
    ],
  ),

  PresentationCollection(
    id: 'love_of_god',
    title: 'The Love That Sent Him',
    subtitle: 'God\'s Boundless Love for Us',
    description:
        'Presentations focused on the astounding love of God — that He '
        'would send His only Son while we were still sinners.',
    icon: Icons.favorite_border,
    color: Color(0xFFD81B60), // Rose
    matchTags: [
      'Love of God',
      'love of God',
      'Love of Christ',
      'love',
      'greatest love',
      'Father\'s Love',
      'proof of love',
      'initiative of God',
      'while we were sinners',
      'Only Begotten Son',
      'Romans 5',
    ],
  ),

  PresentationCollection(
    id: 'lamb_of_god',
    title: 'Behold the Lamb',
    subtitle: 'Jesus as the Perfect Sacrifice',
    description:
        'From John the Baptist\'s declaration to the Lamb on the throne '
        'in Revelation — Jesus as God\'s chosen sacrifice.',
    icon: Icons.brightness_5,
    color: Color(0xFF8E6C2A), // Gold
    matchTags: [
      'Lamb of God',
      'lamb',
      'Lamb on the throne',
      'John the Baptist',
      'Worthy Is the Lamb',
      'Revelation',
      'sinlessness',
      'perfection of Christ',
      'Humility of Christ',
      'Willing Sacrifice',
    ],
  ),

  PresentationCollection(
    id: 'identity_in_christ',
    title: 'Who We Are in Christ',
    subtitle: 'Our Identity at the Table',
    description:
        'Presentations that remind us who we become through Christ\'s '
        'sacrifice — redeemed, forgiven, and made new.',
    icon: Icons.person_pin,
    color: Color(0xFF00695C), // Teal
    matchTags: [
      'Identity in Christ',
      'identity in Christ',
      'identity',
      'identity of Christ',
      'New Creation',
      'new creation',
      'new life',
      'baptism into Christ',
      'raised with Christ',
      'riches of Christ',
      'Personal Salvation',
      'ownership',
      'chosen by God',
      'fellowship',
    ],
  ),
];

/// All collections combined, with seasonal ones first.
List<PresentationCollection> get allCollections =>
    [...seasonalCollections, ...topicalCollections];

/// Collections that are currently "in season" based on the current month.
List<PresentationCollection> get inSeasonCollections =>
    seasonalCollections.where((c) => c.isInSeason).toList();
