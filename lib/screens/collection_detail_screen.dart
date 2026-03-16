import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation_collection.dart';
import '../models/presentation.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/presentation_card.dart';
import 'presentation_detail_screen.dart';

/// Shows all presentations within a specific collection.
class CollectionDetailScreen extends StatelessWidget {
  final PresentationCollection collection;
  final List<Presentation> presentations;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
    required this.presentations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Colored header with collection info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: collection.color,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                collection.title,
                style: const TextStyle(
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
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      collection.color,
                      collection.color.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative icon
                    Positioned(
                      right: -20,
                      top: 20,
                      child: Icon(
                        collection.icon,
                        size: 160,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    // Description text
                    Positioned(
                      left: 24,
                      bottom: 56,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Color(0x66000000),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Description and count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${presentations.length} presentation${presentations.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Presentation list
          if (presentations.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      collection.icon,
                      size: 64,
                      color: collection.color.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No presentations yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'More coming soon!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final presentation = presentations[index];
                  final subProvider =
                      context.watch<SubscriptionProvider>();
                  final isLocked =
                      !subProvider.canAccess(presentation);
                  return PresentationCard(
                    presentation: presentation,
                    isLocked: isLocked,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PresentationDetailScreen(
                            presentation: presentation,
                            isLocked: isLocked,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: presentations.length,
              ),
            ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
