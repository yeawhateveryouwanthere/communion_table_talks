import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scheduled_presentation.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'presentation_detail_screen.dart';

/// Screen showing a history of previously used presentations.
///
/// Displays past presentations (those with dates before today)
/// sorted by most recent first, with the date they were used.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScheduledPresentation> _pastPresentations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final all = await StorageService.loadScheduledPresentations();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final past = all
        .where((s) => s.scheduledDate.isBefore(today))
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    setState(() {
      _pastPresentations = past;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Body
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_pastPresentations.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 48,
                color: AppTheme.accentColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No history yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'After you\'ve given a presentation, it will appear here so you can keep track of what you\'ve used.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            '${_pastPresentations.length} presentation${_pastPresentations.length == 1 ? '' : 's'} given',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ..._pastPresentations.map((item) => _buildHistoryCard(item)),
        const SizedBox(height: 100), // Space for bottom nav
      ]),
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

  Widget _buildHistoryCard(ScheduledPresentation item) {
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
                // Date column
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
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
                          color: AppTheme.primaryColor.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${item.scheduledDate.day}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor.withOpacity(0.7),
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

                // Chevron to indicate it's tappable
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppTheme.textSecondary.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
