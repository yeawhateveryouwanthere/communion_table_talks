import 'package:flutter/material.dart';
import '../models/presentation.dart';
import '../theme/app_theme.dart';

class PresentationCard extends StatelessWidget {
  final Presentation presentation;
  final VoidCallback onTap;

  const PresentationCard({
    super.key,
    required this.presentation,
    required this.onTap,
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
                  Text(
                    presentation.scripturePassage,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
