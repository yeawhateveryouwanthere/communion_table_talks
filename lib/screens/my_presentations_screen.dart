import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scheduled_presentation.dart';
import '../models/presentation.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'select_date_screen.dart';
import 'presentation_detail_screen.dart';
import 'browse_presentations_screen.dart';
import 'collections_screen.dart';

class MyPresentationsScreen extends StatefulWidget {
  const MyPresentationsScreen({super.key});

  @override
  State<MyPresentationsScreen> createState() => _MyPresentationsScreenState();
}

class _MyPresentationsScreenState extends State<MyPresentationsScreen> {
  List<ScheduledPresentation> _scheduled = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScheduled();
  }

  Future<void> _loadScheduled() async {
    final scheduled = await StorageService.loadScheduledPresentations();
    setState(() {
      _scheduled = scheduled;
      _isLoading = false;
    });
  }

  Future<void> _openPresentation(String id) async {
    final presentation = await FirestoreService.getPresentation(id);
    if (presentation != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PresentationDetailScreen(
            presentation: presentation,
          ),
        ),
      );
    }
  }

  Future<void> _removeScheduled(ScheduledPresentation item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Scheduled Presentation'),
        content: Text(
          'Remove "${item.presentationTitle}" from ${DateFormat.yMMMd().format(item.scheduledDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.removeScheduledPresentation(item.scheduledDate);
      _loadScheduled();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = _scheduled
        .where((s) =>
            s.scheduledDate.isAfter(today) ||
            s.scheduledDate.isAtSameMomentAs(today))
        .toList();
    final past = _scheduled
        .where((s) => s.scheduledDate.isBefore(today))
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header with welcoming message
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Communion Table Talks',
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
                  // Background image
                  Image.asset(
                    'assets/images/header_home.jpeg',
                    fit: BoxFit.cover,
                  ),
                  // Dark gradient overlay for readability
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.25),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                  // Welcome text
                  Positioned(
                    left: 24,
                    bottom: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
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
                        const SizedBox(height: 2),
                        Text(
                          _getSubtitle(upcoming),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
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
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Browse All Presentations',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BrowsePresentationsScreen(),
                    ),
                  );
                  _loadScheduled();
                },
              ),
            ],
          ),

          // Body content
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_scheduled.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            _buildScheduleListSliver(upcoming, past),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SelectDateScreen(),
            ),
          );
          _loadScheduled();
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'Plan a Presentation',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getSubtitle(List<ScheduledPresentation> upcoming) {
    if (upcoming.isEmpty) return 'No upcoming presentations';
    if (upcoming.length == 1) return '1 upcoming presentation';
    return '${upcoming.length} upcoming presentations';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative icon with gold accent
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book,
                size: 48,
                color: AppTheme.accentColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Ready to prepare?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Plan your next Lord\'s Supper presentation by picking a date and choosing a talk that speaks to you.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Browse button
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BrowsePresentationsScreen(),
                  ),
                );
                _loadScheduled();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Browse presentations'),
            ),
            const SizedBox(height: 12),
            // Collections button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CollectionsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentDark,
                side: BorderSide(
                  color: AppTheme.accentColor.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.collections_bookmark, size: 18),
              label: const Text('Seasonal & topical collections'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleListSliver(
      List<ScheduledPresentation> upcoming, List<ScheduledPresentation> past) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 20),

        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          _buildSectionHeader('Upcoming', Icons.event, AppTheme.primaryColor),
          ...upcoming.map((item) => _buildScheduledCard(item, isUpcoming: true)),
          const SizedBox(height: 12),
        ],

        // Past section
        if (past.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionHeader('Past', Icons.history, AppTheme.textSecondary),
          ...past.map((item) => _buildScheduledCard(item, isUpcoming: false)),
        ],

        // Browse and Collections links at bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: Center(
            child: Column(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BrowsePresentationsScreen(),
                      ),
                    );
                    _loadScheduled();
                  },
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text('Browse all presentations'),
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CollectionsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.collections_bookmark, size: 18),
                  label: const Text('Seasonal & topical collections'),
                ),
              ],
            ),
          ),
        ),

        // Space for FAB
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: color.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  String _timeForLabel(String label) {
    switch (label) {
      case 'Brief':
        return '2–3 min';
      case 'Medium':
        return '4–6 min';
      case 'Substantive':
        return '7–10 min';
      default:
        return '';
    }
  }

  Widget _buildScheduledCard(ScheduledPresentation item,
      {required bool isUpcoming}) {
    final dateFormatted = DateFormat.yMMMd().format(item.scheduledDate);
    final dayOfWeek = DateFormat.EEEE().format(item.scheduledDate);
    final lengthColor = AppTheme.lengthColor(item.lengthLabel);

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
          onTap: () => _openPresentation(item.presentationId),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date column with accent border
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? AppTheme.primaryColor.withOpacity(0.08)
                        : AppTheme.textSecondary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: isUpcoming
                        ? Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.MMM()
                            .format(item.scheduledDate)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isUpcoming
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${item.scheduledDate.day}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isUpcoming
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$dayOfWeek, $dateFormatted',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.presentationTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.menu_book,
                              size: 13, color: AppTheme.accentColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.scripturePassage,
                              style: TextStyle(
                                color: AppTheme.primaryColor.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: lengthColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppTheme.lengthIcon(item.lengthLabel),
                              size: 12,
                              color: lengthColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.lengthLabel} · ${_timeForLabel(item.lengthLabel)}',
                              style: TextStyle(
                                color: lengthColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  icon: Icon(Icons.close,
                      size: 18,
                      color: AppTheme.textSecondary.withOpacity(0.4)),
                  onPressed: () => _removeScheduled(item),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
