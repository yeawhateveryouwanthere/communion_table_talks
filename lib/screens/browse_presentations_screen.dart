import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/presentation.dart';
import '../models/scheduled_presentation.dart';
import '../data/sample_presentations.dart';
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

  const BrowsePresentationsScreen({
    super.key,
    this.scheduledDate,
    this.filterLength,
    this.filterPassage,
    this.filterTopic,
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

  @override
  void initState() {
    super.initState();
    _selectedLength = widget.filterLength;

    // Combine passage and topic filters into the search query
    final initialSearch = <String>[];
    if (widget.filterPassage != null && widget.filterPassage!.isNotEmpty) {
      initialSearch.add(widget.filterPassage!);
    }
    if (widget.filterTopic != null && widget.filterTopic!.isNotEmpty) {
      initialSearch.add(widget.filterTopic!);
    }
    _searchQuery = initialSearch.join(' ');
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _allTopics {
    final topics = <String>{};
    for (final p in samplePresentations) {
      topics.addAll(p.topicTags);
    }
    final sorted = topics.toList()..sort();
    return sorted;
  }

  List<Presentation> get _filteredPresentations {
    return samplePresentations.where((p) {
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
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      // Pop back to the home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPresentations;
    final isScheduling = widget.scheduledDate != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isScheduling
            ? 'Select Presentation'
            : 'Browse Presentations'),
      ),
      body: Column(
        children: [
          // Date banner if scheduling
          if (isScheduling)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.accentColor.withOpacity(0.15),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Presenting on ${DateFormat.EEEE().format(widget.scheduledDate!)}, ${DateFormat.yMMMd().format(widget.scheduledDate!)}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title, passage, or topic...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLengthChip('Brief', PresentationLength.brief),
                const SizedBox(width: 8),
                _buildLengthChip('Medium', PresentationLength.medium),
                const SizedBox(width: 8),
                _buildLengthChip('Substantive', PresentationLength.substantive),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: AppTheme.dividerColor,
                ),
                const SizedBox(width: 12),
                _buildTopicDropdown(),
                if (_hasActiveFilters) ...[
                  const SizedBox(width: 12),
                  ActionChip(
                    label: const Text('Clear All'),
                    avatar: const Icon(Icons.clear, size: 16),
                    onPressed: _clearFilters,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filtered.length} presentation${filtered.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Presentation list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No presentations found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final presentation = filtered[index];
                      return PresentationCard(
                        presentation: presentation,
                        scheduledDate: widget.scheduledDate,
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PresentationDetailScreen(
                                presentation: presentation,
                                scheduledDate: widget.scheduledDate,
                              ),
                            ),
                          );
                          // If the user selected this presentation from
                          // the detail screen, pop back to home.
                          if (result == true && mounted) {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                        onUsePresentation: isScheduling
                            ? () => _usePresentation(presentation)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLengthChip(String label, PresentationLength length) {
    final isSelected = _selectedLength == length;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.lengthColor(label).withOpacity(0.2),
      checkmarkColor: AppTheme.lengthColor(label),
      onSelected: (selected) {
        setState(() {
          _selectedLength = selected ? length : null;
        });
      },
    );
  }

  Widget _buildTopicDropdown() {
    return PopupMenuButton<String>(
      onSelected: (topic) {
        setState(() {
          _selectedTopic = _selectedTopic == topic ? null : topic;
        });
      },
      itemBuilder: (context) {
        return _allTopics.map((topic) {
          return PopupMenuItem<String>(
            value: topic,
            child: Row(
              children: [
                if (_selectedTopic == topic)
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
        label: Text(_selectedTopic ?? 'Topic'),
        avatar: const Icon(Icons.label_outline, size: 16),
        backgroundColor: _selectedTopic != null
            ? AppTheme.primaryColor.withOpacity(0.1)
            : null,
      ),
    );
  }
}
