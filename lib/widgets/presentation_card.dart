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

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Length badge and date
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: lengthColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      presentation.lengthLabel,
                      style: TextStyle(
                        color: lengthColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(presentation.datePublished),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                presentation.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 4),

              // Scripture passage
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 14,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      presentation.scripturePassage,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Summary
              Text(
                presentation.summary,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Topic tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: presentation.topicTags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // "Use this presentation" button
              if (onUsePresentation != null && scheduledDate != null) ...[
                const SizedBox(height: 12),
                const Divider(color: AppTheme.dividerColor),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUsePresentation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
