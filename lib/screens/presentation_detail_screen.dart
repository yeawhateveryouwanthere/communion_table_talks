import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/presentation.dart';
import '../models/scheduled_presentation.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PresentationDetailScreen extends StatelessWidget {
  final Presentation presentation;
  final DateTime? scheduledDate;

  const PresentationDetailScreen({
    super.key,
    required this.presentation,
    this.scheduledDate,
  });

  Future<void> _usePresentation(BuildContext context) async {
    if (scheduledDate == null) return;

    final scheduled = ScheduledPresentation(
      presentationId: presentation.id,
      presentationTitle: presentation.title,
      scripturePassage: presentation.scripturePassage,
      lengthLabel: presentation.lengthLabel,
      scheduledDate: scheduledDate!,
    );

    await StorageService.saveScheduledPresentation(scheduled);

    if (context.mounted) {
      final dateStr = DateFormat.yMMMd().format(scheduledDate!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${presentation.title}" scheduled for $dateStr',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      // Return true to signal that a presentation was selected
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lengthColor = AppTheme.lengthColor(presentation.lengthLabel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communion Table Talks'),
      ),
      body: Column(
        children: [
          // Date banner if scheduling
          if (scheduledDate != null)
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
                    'Presenting on ${DateFormat.EEEE().format(scheduledDate!)}, ${DateFormat.yMMMd().format(scheduledDate!)}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Length badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                  const Divider(color: AppTheme.dividerColor),
                  const SizedBox(height: 16),

                  // Body text
                  _buildBodyText(context),

                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.dividerColor),
                  const SizedBox(height: 16),

                  // Suggested Hymns
                  if (presentation.suggestedHymns.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.music_note,
                            size: 20, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Suggested Hymns',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom "Use this presentation" button
          if (scheduledDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _usePresentation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.check),
                label: Text(
                  'Use this presentation for ${DateFormat.MMMd().format(scheduledDate!)}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBodyText(BuildContext context) {
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

  Widget _buildRichParagraph(BuildContext context, String html) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'<(/?)(em|strong|b|i)>');
    bool isBold = false;
    bool isItalic = false;

    int lastEnd = 0;
    for (final match in regex.allMatches(html)) {
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

      final isClosing = match.group(1) == '/';
      final tag = match.group(2);

      if (tag == 'strong' || tag == 'b') {
        isBold = !isClosing;
      } else if (tag == 'em' || tag == 'i') {
        isItalic = !isClosing;
      }

      lastEnd = match.end;
    }

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
