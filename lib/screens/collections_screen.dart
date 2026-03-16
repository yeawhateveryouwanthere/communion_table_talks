import 'package:flutter/material.dart';
import '../data/collections_data.dart';
import '../models/presentation_collection.dart';
import '../models/presentation.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'collection_detail_screen.dart';

/// Screen displaying curated seasonal and topical collections.
///
/// Collections are organized into two sections:
/// 1. Seasonal — highlighted when they're "in season"
/// 2. Topical — always available
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  List<Presentation> _allPresentations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPresentations();
  }

  Future<void> _loadPresentations() async {
    final presentations = await FirestoreService.getAllPresentations();
    setState(() {
      _allPresentations = presentations;
      _isLoading = false;
    });
  }

  /// Count how many presentations match a given collection's tags.
  int _countForCollection(PresentationCollection collection) {
    return _allPresentations.where((p) {
      return p.topicTags
          .any((tag) => collection.matchTags.contains(tag));
    }).length;
  }

  void _openCollection(PresentationCollection collection) {
    final matching = _allPresentations.where((p) {
      return p.topicTags
          .any((tag) => collection.matchTags.contains(tag));
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionDetailScreen(
          collection: collection,
          presentations: matching,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inSeason = inSeasonCollections;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Collections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Color(0x88000000),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/header_browse.jpeg',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            // "In Season" highlight section
            if (inSeason.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 18, color: AppTheme.accentDark),
                      const SizedBox(width: 8),
                      Text(
                        'In Season Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.primaryColor.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: inSeason.length,
                    itemBuilder: (context, index) {
                      return _buildFeaturedCard(inSeason[index]);
                    },
                  ),
                ),
              ),
            ],

            // Seasonal Collections section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Seasonal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.primaryColor.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildCollectionTile(seasonalCollections[index]);
                },
                childCount: seasonalCollections.length,
              ),
            ),

            // Topical Collections section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.bookmark_outline,
                        size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Topical',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppTheme.primaryColor.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildCollectionTile(topicalCollections[index]);
                },
                childCount: topicalCollections.length,
              ),
            ),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ],
      ),
    );
  }

  /// Featured horizontal card for "in season" collections.
  Widget _buildFeaturedCard(PresentationCollection collection) {
    final count = _countForCollection(collection);
    return GestureDetector(
      onTap: () => _openCollection(collection),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              collection.color,
              collection.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: collection.color.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                collection.icon,
                size: 32,
                color: Colors.white.withOpacity(0.9),
              ),
              const Spacer(),
              Text(
                collection.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count presentation${count == 1 ? '' : 's'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// List tile for a collection in the main list.
  Widget _buildCollectionTile(PresentationCollection collection) {
    final count = _countForCollection(collection);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openCollection(collection),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: collection.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    collection.icon,
                    size: 24,
                    color: collection.color,
                  ),
                ),
                const SizedBox(width: 14),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        collection.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: collection.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: collection.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary.withOpacity(0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
