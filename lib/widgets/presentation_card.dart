import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/presentation.dart';
import '../theme/app_theme.dart';

class PresentationCard extends StatelessWidget {
  final Presentation presentation;
  final VoidCallback onTap;
  final DateTime? scheduledDate;
  final VoidCallback? onUsePresentation;

  const PresentationCard({
    super.key,
    required this.presentation,
    required this.onTap,
    this.scheduledDate,
    this.onUsePresentation,
  });

  @override
  Widget build(BuildContext context) {
    final lengthColor = AppTheme.lengthColor(presentation.lengthLabel);

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Length badge and date row
                Row(
                  children: [
                    // Length badge with icon
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: lengthColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: lengthColor.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppTheme.lengthIcon(presentation.lengthLabel),
                            size: 12,
                            color: lengthColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            presentation.lengthLabel,
                            style: TextStyle(
                              color: lengthColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(presentation.datePublished),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  presentation.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 6),

                // Scripture passage with styled row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 13,
                        color: AppTheme.accentDark,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          presentation.scripturePassage,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Summary
                Text(
                  presentation.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Topic tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: presentation.topicTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // "Use this presentation" button
                if (onUsePresentation != null && scheduledDate != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    height: 1,
                    color: AppTheme.dividerColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onUsePresentation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        'Use this for ${DateFormat.MMMd().format(scheduledDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
