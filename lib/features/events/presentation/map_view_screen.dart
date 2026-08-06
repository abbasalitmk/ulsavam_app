import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../districts/providers/districts_provider.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class MapViewScreen extends ConsumerWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtName = ref.watch(selectedDistrictNameProvider);
    final districtSlug = ref.watch(selectedDistrictSlugProvider);
    final eventsAsync = ref.watch(exploreEventsProvider({'district': districtSlug}));

    return Scaffold(
      appBar: AppBar(
        title: Text('Map View - $districtName', style: AppTypography.titleMedium),
      ),
      body: Stack(
        children: [
          // Styled Map Placeholder representation
          Container(
            color: AppColors.surfaceContainerHigh,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 80, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text('Interactive Kerala Event Map', style: AppTypography.headlineLarge),
                  const SizedBox(height: 8),
                  Text('Showing geo-tagged festivals in $districtName', style: AppTypography.bodySmall),
                ],
              ),
            ),
          ),

          // Event Card Carousel at bottom
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            height: 120,
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) return const SizedBox();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
                        );
                      },
                      child: Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                                image: event.coverImage != null && event.coverImage!.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(event.coverImage!), fit: BoxFit.cover)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(event.title, style: AppTypography.titleMedium.copyWith(fontSize: 14), maxLines: 1),
                                  Text(event.venueName, style: AppTypography.bodySmall, maxLines: 1),
                                  const SizedBox(height: 4),
                                  Text('${event.goingCount} Going', style: AppTypography.labelMedium.copyWith(fontSize: 10)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
