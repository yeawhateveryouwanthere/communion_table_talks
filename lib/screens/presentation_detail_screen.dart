import 'package:flutter/material.dart';
import '../models/presentation.dart';
import '../theme/app_theme.dart';

class PresentationDetailScreen extends StatelessWidget {
  final Presentation presentation;

  const PresentationDetailScreen({
    super.key,
    required this.presentation,
  });

  @override
  Widget build(BuildContext context) {
    final lengthColor = AppTheme.lengthColor(presentation.lengthLabel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communion Table Talks'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Length badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: lengthColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                presentation.lengthLabel,
                style: TextStyle(
                  color: lengthColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              presentation.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            // Scripture passage
            Row(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 18,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  presentation.scripturePassage,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Divider
            const Divider(color: AppTheme.dividerColor),

            const SizedBox(height: 16),

            // Body text (rendered from simple HTML)
            _buildBodyText(context),

            const SizedBox(height: 24),

            // Divider
            const Divider(color: AppTheme.dividerColor),

            const SizedBox(height: 16),

            // Suggested Hymns section
            if (presentation.suggestedHymns.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.music_note,
                    size: 20,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Suggested Hymns',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...presentation.suggestedHymns.map((hymn) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 16,
                          )),
                      Expanded(
                        child: Text(
                          hymn,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.dividerColor),
              const SizedBox(height: 16),
            ],

            // Topic tags
            Text(
              'Topics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: presentation.topicTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Renders the body text with basic HTML formatting support.
  ///
  /// Supports <p>, <em>, <strong>, and <br> tags.
  /// For a production app, consider using the flutter_html package.
  Widget _buildBodyText(BuildContext context) {
    // Simple HTML to styled text conversion.
    // Strip tags and render as styled paragraphs.
    final paragraphs = presentation.bodyText
        .split(RegExp(r'</?p>'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRichParagraph(context, paragraph.trim()),
        );
      }).toList(),
    );
  }

  /// Converts a paragraph with basic HTML tags into a RichText widget.
  Widget _buildRichParagraph(BuildContext context, String html) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'<(/?)(em|strong|b|i)>');
    bool isBold = false;
    bool isItalic = false;

    int lastEnd = 0;
    for (final match in regex.allMatches(html)) {
      // Add text before this tag
      if (match.start > lastEnd) {
        final text = _cleanHtml(html.substring(lastEnd, match.start));
        if (text.isNotEmpty) {
          spans.add(TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ));
        }
      }

      // Process the tag
      final isClosing = match.group(1) == '/';
      final tag = match.group(2);

      if (tag == 'strong' || tag == 'b') {
        isBold = !isClosing;
      } else if (tag == 'em' || tag == 'i') {
        isItalic = !isClosing;
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < html.length) {
      final text = _cleanHtml(html.substring(lastEnd));
      if (text.isNotEmpty) {
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyLarge,
        children: spans.isEmpty ? [TextSpan(text: _cleanHtml(html))] : spans,
      ),
    );
  }

  /// Remove any remaining HTML tags and decode basic entities.
  String _cleanHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
