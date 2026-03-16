import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/presentation.dart';
import '../models/scheduled_presentation.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/presentation_card.dart';
import 'presentation_detail_screen.dart';

/// Screen for browsing and filtering presentations.
///
/// Can be used in two modes:
/// 1. With a [scheduledDate] — user is picking a presentation for a specific date
/// 2. Without a date — user is just browsing
class BrowsePresentationsScreen extends StatefulWidget {
  final DateTime? scheduledDate;
  final PresentationLength? filterLength;
  final String? filterPassage;
  final String? filterTopic;
  final bool isTab;

  const BrowsePresentationsScreen({
    super.key,
    this.scheduledDate,
    this.filterLength,
    this.filterPassage,
    this.filterTopic,
    this.isTab = false,
  });

  @override
  State<BrowsePresentationsScreen> createState() =>
      _BrowsePresentationsScreenState();
}

class _BrowsePresentationsScreenState extends State<BrowsePresentationsScreen> {
  late TextEditingController _searchController;
  late String _searchQuery;
  PresentationLength? _selectedLength;
  String? _selectedTopic;
  List<Presentation> _allPresentations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedLength = widget.filterLength;

    final initialSearch = <String>[];
    if (widget.filterPassage != null && widget.filterPassage!.isNotEmpty) {
      initialSearch.add(widget.filterPassage!);
    }
    if (widget.filterTopic != null && widget.filterTopic!.isNotEmpty) {
      initialSearch.add(widget.filterTopic!);
    }
    _searchQuery = initialSearch.join(' ');
    _searchController = TextEditingController(text: _searchQuery);

    _loadPresentations();
  }

  Future<void> _loadPresentations() async {
    final presentations = await FirestoreService.getAllPresentations();
    setState(() {
      _allPresentations = presentations;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _allTopics {
    final topics = <String>{};
    for (final p in _allPresentations) {
      topics.addAll(p.topicTags);
    }
    final sorted = topics.toList()..sort();
    return sorted;
  }

  List<Presentation> get _filteredPresentations {
    return _allPresentations.where((p) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesPassage =
            p.scripturePassage.toLowerCase().contains(query);
        final matchesSummary = p.summary.toLowerCase().contains(query);
        final matchesTopic =
            p.topicTags.any((t) => t.toLowerCase().contains(query));
        if (!matchesTitle &&
            !matchesPassage &&
            !matchesSummary &&
            !matchesTopic) {
          return false;
        }
      }
      if (_selectedLength != null && p.length != _selectedLength) {
        return false;
      }
      if (_selectedTopic != null && !p.topicTags.contains(_selectedTopic)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedLength = null;
      _selectedTopic = null;
    });
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedLength != null ||
      _selectedTopic != null;

  Future<void> _usePresentation(Presentation presentation) async {
    if (widget.scheduledDate == null) return;

    final scheduled = ScheduledPresentation(
      presentationId: presentation.id,
      presentationTitle: presentation.title,
      scripturePassage: presentation.scripturePassage,
      lengthLabel: presentation.lengthLabel,
      scheduledDate: widget.scheduledDate!,
    );

    await StorageService.saveScheduledPresentation(scheduled);

    if (mounted) {
      final dateStr = DateFormat.yMMMd().format(widget.scheduledDate!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${presentation.title}" scheduled for $dateStr',
          ),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isScheduling = widget.scheduledDate != null;
    final filtered = _filteredPresentations;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header — collapses on scroll, title stays pinned
          SliverAppBar(
            expandedHeight: isScheduling ? 140 : 160,
            pinned: true,
            automaticallyImplyLeading: !widget.isTab,
            backgroundColor: AppTheme.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                isScheduling ? 'Select Presentation' : 'Browse Presentations',
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

          // Sticky search bar and filter chips
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyFilterDelegate(
              isScheduling: isScheduling,
              scheduledDate: widget.scheduledDate,
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSearchCleared: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              selectedLength: _selectedLength,
              onLengthSelected: (length) {
                setState(() {
                  _selectedLength =
                      _selectedLength == length ? null : length;
                });
              },
              selectedTopic: _selectedTopic,
              allTopics: _allTopics,
              onTopicSelected: (topic) {
                setState(() {
                  _selectedTopic =
                      _selectedTopic == topic ? null : topic;
                });
              },
              hasActiveFilters: _hasActiveFilters,
              onClearFilters: _clearFilters,
              filteredCount: filtered.length,
            ),
          ),

          // Presentation list
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_off,
                        size: 40,
                        color: AppTheme.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No presentations found',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear filters'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final presentation = filtered[index];
                  final subProvider =
                      context.watch<SubscriptionProvider>();
                  final isLocked =
                      !subProvider.canAccess(presentation);
                  return PresentationCard(
                    presentation: presentation,
                    scheduledDate: widget.scheduledDate,
                    isLocked: isLocked,
                    onTap: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PresentationDetailScreen(
                            presentation: presentation,
                            scheduledDate: widget.scheduledDate,
                            isLocked: isLocked,
                          ),
                        ),
                      );
                      if (result == true && mounted) {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    },
                    onUsePresentation: isScheduling && !isLocked
                        ? () => _usePresentation(presentation)
                        : null,
                  );
                },
                childCount: filtered.length,
              ),
            ),

          // Bottom padding for nav bar
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

}

/// Persistent header delegate that pins the search bar, filter chips,
/// and result count below the collapsing image header.
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final bool isScheduling;
  final DateTime? scheduledDate;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final PresentationLength? selectedLength;
  final ValueChanged<PresentationLength> onLengthSelected;
  final String? selectedTopic;
  final List<String> allTopics;
  final ValueChanged<String> onTopicSelected;
  final bool hasActiveFilters;
  final VoidCallback onClearFilters;
  final int filteredCount;

  _StickyFilterDelegate({
    required this.isScheduling,
    required this.scheduledDate,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.selectedLength,
    required this.onLengthSelected,
    required this.selectedTopic,
    required this.allTopics,
    required this.onTopicSelected,
    required this.hasActiveFilters,
    required this.onClearFilters,
    required this.filteredCount,
  });

  // Date banner ~40, search ~64, filter chips ~56, count ~32, spacing ~12
  double get _dateBannerHeight => isScheduling ? 40.0 : 0.0;

  @override
  double get maxExtent => _dateBannerHeight + 164;

  @override
  double get minExtent => _dateBannerHeight + 164;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date banner if scheduling
          if (isScheduling)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.12),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.accentColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 15, color: AppTheme.accentDark),
                  const SizedBox(width: 8),
                  Text(
                    'Presenting on ${DateFormat.EEEE().format(scheduledDate!)}, ${DateFormat.yMMMd().format(scheduledDate!)}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by title, passage, or topic...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search,
                      color: AppTheme.primaryColor.withOpacity(0.5)),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: AppTheme.textSecondary.withOpacity(0.5)),
                          onPressed: onSearchCleared,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryColor, width: 1.5),
                  ),
                ),
                onChanged: onSearchChanged,
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLengthChip(context, 'Brief', PresentationLength.brief),
                const SizedBox(width: 8),
                _buildLengthChip(context, 'Medium', PresentationLength.medium),
                const SizedBox(width: 8),
                _buildLengthChip(
                    context, 'Substantive', PresentationLength.substantive),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  color: AppTheme.dividerColor,
                ),
                const SizedBox(width: 12),
                _buildTopicDropdown(context),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 12),
                  ActionChip(
                    label: const Text('Clear All'),
                    avatar: const Icon(Icons.clear, size: 14),
                    onPressed: onClearFilters,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              '$filteredCount presentation${filteredCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLengthChip(
      BuildContext context, String label, PresentationLength length) {
    final isSelected = selectedLength == length;
    final color = AppTheme.lengthColor(label);
    return FilterChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(AppTheme.lengthIcon(label), size: 14, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _timeForLabel(label),
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? color.withOpacity(0.8)
                  : Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.6),
            ),
          ),
        ],
      ),
      selected: isSelected,
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: isSelected
          ? BorderSide(color: color.withOpacity(0.3))
          : BorderSide.none,
      onSelected: (_) => onLengthSelected(length),
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

  Widget _buildTopicDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onTopicSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) {
        return allTopics.map((topic) {
          return PopupMenuItem<String>(
            value: topic,
            child: Row(
              children: [
                if (selectedTopic == topic)
                  const Icon(Icons.check,
                      size: 16, color: AppTheme.primaryColor)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(topic),
              ],
            ),
          );
        }).toList();
      },
      child: Chip(
        label: Text(selectedTopic ?? 'Topic'),
        avatar: const Icon(Icons.label_outline, size: 16),
        backgroundColor: selectedTopic != null
            ? AppTheme.primaryColor.withOpacity(0.1)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return searchQuery != oldDelegate.searchQuery ||
        selectedLength != oldDelegate.selectedLength ||
        selectedTopic != oldDelegate.selectedTopic ||
        hasActiveFilters != oldDelegate.hasActiveFilters ||
        filteredCount != oldDelegate.filteredCount;
  }
}
