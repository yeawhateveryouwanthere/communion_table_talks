import 'package:flutter/material.dart';
import '../models/presentation.dart';
import '../data/sample_presentations.dart';
import '../theme/app_theme.dart';
import '../widgets/presentation_card.dart';
import 'presentation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PresentationLength? _selectedLength;
  String? _selectedTopic;

  /// Get all unique topics from the presentations.
  List<String> get _allTopics {
    final topics = <String>{};
    for (final p in samplePresentations) {
      topics.addAll(p.topicTags);
    }
    final sorted = topics.toList()..sort();
    return sorted;
  }

  /// Filter presentations based on current search and filter state.
  List<Presentation> get _filteredPresentations {
    return samplePresentations.where((p) {
      // Search query matches title, passage, summary, or topics
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesPassage = p.scripturePassage.toLowerCase().contains(query);
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

      // Length filter
      if (_selectedLength != null && p.length != _selectedLength) {
        return false;
      }

      // Topic filter
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPresentations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communion Table Talks'),
      ),
      body: Column(
        children: [
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
                // Length filter chips
                _buildLengthChip('Brief', PresentationLength.brief),
                const SizedBox(width: 8),
                _buildLengthChip('Medium', PresentationLength.medium),
                const SizedBox(width: 8),
                _buildLengthChip('Substantive', PresentationLength.substantive),
                const SizedBox(width: 12),
                // Divider
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: AppTheme.dividerColor,
                ),
                const SizedBox(width: 12),
                // Topic dropdown
                _buildTopicDropdown(),
                // Clear filters
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PresentationDetailScreen(
                                presentation: presentation,
                              ),
                            ),
                          );
                        },
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
                  const Icon(Icons.check, size: 16, color: AppTheme.primaryColor)
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
