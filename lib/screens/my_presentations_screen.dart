import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scheduled_presentation.dart';
import '../models/presentation.dart';
import '../data/sample_presentations.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'select_date_screen.dart';
import 'presentation_detail_screen.dart';
import 'browse_presentations_screen.dart';

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

  /// Find the full presentation object by ID.
  Presentation? _findPresentation(String id) {
    try {
      return samplePresentations.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _removeScheduled(ScheduledPresentation item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
    // Split into upcoming and past
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
      appBar: AppBar(
        title: const Text('Communion Table Talks'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scheduled.isEmpty
              ? _buildEmptyState()
              : _buildScheduleList(upcoming, past),
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
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Plan a Presentation'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 72,
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No presentations scheduled yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap "Plan a Presentation" below to pick a date and find the perfect Lord\'s Supper talk.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
              icon: const Icon(Icons.menu_book),
              label: const Text('Or just browse presentations'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList(
      List<ScheduledPresentation> upcoming, List<ScheduledPresentation> past) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      children: [
        // Upcoming section
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Upcoming',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
          ),
          ...upcoming.map((item) => _buildScheduledCard(item, isUpcoming: true)),
        ],

        // Past section
        if (past.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Past',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          ...past.map((item) => _buildScheduledCard(item, isUpcoming: false)),
        ],

        // Browse link at bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BrowsePresentationsScreen(),
                  ),
                );
                _loadScheduled();
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('Browse all presentations'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledCard(ScheduledPresentation item,
      {required bool isUpcoming}) {
    final dateFormatted = DateFormat.yMMMd().format(item.scheduledDate);
    final dayOfWeek = DateFormat.EEEE().format(item.scheduledDate);
    final lengthColor = AppTheme.lengthColor(item.lengthLabel);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          final presentation = _findPresentation(item.presentationId);
          if (presentation != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PresentationDetailScreen(
                  presentation: presentation,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date column
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.textSecondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat.MMM().format(item.scheduledDate).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isUpcoming
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${item.scheduledDate.day}',
                      style: TextStyle(
                        fontSize: 22,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.menu_book,
                            size: 13, color: AppTheme.accentColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.scripturePassage,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: lengthColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.lengthLabel,
                        style: TextStyle(
                          color: lengthColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: Icon(Icons.close,
                    size: 18, color: AppTheme.textSecondary.withOpacity(0.5)),
                onPressed: () => _removeScheduled(item),
                tooltip: 'Remove',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
