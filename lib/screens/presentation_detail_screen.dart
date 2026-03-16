import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/presentation.dart';
import '../models/scheduled_presentation.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/paywall_bottom_sheet.dart';
import 'presenter_view_screen.dart';

class PresentationDetailScreen extends StatelessWidget {
  final Presentation presentation;
  final DateTime? scheduledDate;
  final bool isLocked;

  const PresentationDetailScreen({
    super.key,
    required this.presentation,
    this.scheduledDate,
    this.isLocked = false,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lengthColor = AppTheme.lengthColor(presentation.lengthLabel);

    return Scaffold(
      body: Column(
        children: [
          // Image header with title info
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/header_detail.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          // Length badge in header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppTheme.lengthIcon(presentation.lengthLabel),
                                  size: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  presentation.lengthWithTime,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isLocked) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 13,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Premium',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),

                    // Title and scripture
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          presentation.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: -0.2,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 4,
                                color: Color(0x88000000),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: 16,
                              color: AppTheme.accentLight,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              presentation.scripturePassage,
                              style: TextStyle(
                                color: AppTheme.accentLight,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),

          // Date banner if scheduling
          if (scheduledDate != null)
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

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Body text — the main reading content
                  if (isLocked)
                    _buildLockedContent(context)
                  else
                    _buildBodyText(context),

                  if (!isLocked) ...[
                  const SizedBox(height: 28),

                  // Presenter's View button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PresenterViewScreen(
                              presentation: presentation,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF1A1A1A),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.tv, size: 20),
                      label: const Text(
                        'Presenter\'s View',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Divider with decorative element
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                            height: 1, color: AppTheme.dividerColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.local_florist,
                          size: 16,
                          color: AppTheme.accentColor.withOpacity(0.5),
                        ),
                      ),
                      Expanded(
                        child: Container(
                            height: 1, color: AppTheme.dividerColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  ], // end !isLocked divider section

                  // Suggested Hymns
                  if (!isLocked && presentation.suggestedHymns.isNotEmpty) ...[
                    _buildSectionLabel(context, 'Suggested Hymns',
                        Icons.music_note),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            presentation.suggestedHymns.map((hymn) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.music_note,
                                    size: 14,
                                    color: AppTheme.accentDark
                                        .withOpacity(0.5)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hymn,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (isLocked)
                    const SizedBox(height: 24),

                  // Topic tags (always show, even for locked)
                  _buildSectionLabel(context, 'Topics', Icons.label_outline),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: presentation.topicTags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor.withOpacity(0.75),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom "Use this presentation" button (hidden for locked content)
          if (scheduledDate != null && !isLocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, -2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _usePresentation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildSectionLabel(
      BuildContext context, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 32,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Premium Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to read the full presentation text, suggested hymns, and more.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                PaywallBottomSheet.show(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.star, size: 18),
              label: const Text(
                'Subscribe to Unlock',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
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
      children: paragraphs.asMap().entries.map((entry) {
        final index = entry.key;
        final paragraph = entry.value.trim();

        // First paragraph gets a drop-cap–like larger first line
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < paragraphs.length - 1 ? 18 : 0,
          ),
          child: _buildRichParagraph(context, paragraph),
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.75,
            ),
        children:
            spans.isEmpty ? [TextSpan(text: _cleanHtml(html))] : spans,
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
