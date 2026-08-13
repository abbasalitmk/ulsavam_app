import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/events/domain/event_model.dart';
import '../../features/events/presentation/event_detail_screen.dart';

const _kMonthAbbreviations = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC'
];

/// A compact event row with a thumbnail, title/venue, and a month/day date
/// badge. Used anywhere a dense, scannable event list is shown (home's
/// "This Week" section, the event calendar's day list).
class EventDateCard extends StatelessWidget {
  final EventModel event;

  const EventDateCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(event.eventDate);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 68,
                height: 68,
                color: AppColors.primaryContainer,
                child: event.coverImage != null && event.coverImage!.isNotEmpty
                    ? Image.network(event.coverImage!, fit: BoxFit.cover)
                    : const Icon(Icons.festival, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: EventBadge(
                            text: '${event.goingCount} Going',
                            color: AppColors.secondaryContainer,
                            textColor: AppColors.onSecondaryContainer),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: EventBadge(
                          text: event.status == 'verified'
                              ? 'Verified'
                              : 'Pending',
                          color: event.status == 'verified'
                              ? AppColors.tertiaryContainer.withOpacity(0.15)
                              : AppColors.secondaryContainer.withOpacity(0.4),
                          textColor: event.status == 'verified'
                              ? AppColors.tertiaryContainer
                              : AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    parsedDate != null
                        ? _kMonthAbbreviations[parsedDate.month - 1]
                        : '',
                    style: AppTypography.labelMedium
                        .copyWith(fontSize: 10, color: AppColors.primary),
                  ),
                  Text(
                    parsedDate != null ? '${parsedDate.day}' : '-',
                    style: AppTypography.titleMedium.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Same content as [EventDateCard] but laid out as a grid tile (image on
/// top, date badge inline at the bottom) for grid-view calendar layouts.
class EventGridDateCard extends StatelessWidget {
  final EventModel event;

  const EventGridDateCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 84,
                width: double.infinity,
                color: AppColors.primaryContainer,
                child: event.coverImage != null && event.coverImage!.isNotEmpty
                    ? Image.network(event.coverImage!, fit: BoxFit.cover)
                    : const Icon(Icons.festival, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: AppTypography.titleMedium.copyWith(fontSize: 13.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    event.venueName,
                    style: AppTypography.labelMedium.copyWith(
                        fontSize: 10, color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EventBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const EventBadge(
      {required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style:
            AppTypography.labelMedium.copyWith(fontSize: 10, color: textColor),
      ),
    );
  }
}
