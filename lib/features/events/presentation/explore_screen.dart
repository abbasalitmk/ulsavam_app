import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../districts/providers/districts_provider.dart';
import '../providers/events_provider.dart';
import '../domain/event_model.dart';
import 'event_detail_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _selectedCategory;
  bool _verifiedOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final districtSlug = ref.watch(selectedDistrictSlugProvider);
    final eventsAsync = ref.watch(
      exploreEventsProvider({
        'district': districtSlug,
        'category': _selectedCategory,
        'verified_only': _verifiedOnly,
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Events', style: AppTypography.titleMedium),
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onSelected: (val) => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Temple Pooram'),
                  selected: _selectedCategory == 'temple',
                  onSelected: (val) => setState(() => _selectedCategory = val ? 'temple' : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Church Feast'),
                  selected: _selectedCategory == 'church',
                  onSelected: (val) => setState(() => _selectedCategory = val ? 'church' : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('DJ & Music'),
                  selected: _selectedCategory == 'dj_music',
                  onSelected: (val) => setState(() => _selectedCategory = val ? 'dj_music' : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Verified Only'),
                  selected: _verifiedOnly,
                  selectedColor: AppColors.tertiaryContainer.withOpacity(0.2),
                  onSelected: (val) => setState(() => _verifiedOnly = val),
                ),
              ],
            ),
          ),

          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('No events found matching your filters.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventListItem(context, event);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading events: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventListItem(BuildContext context, EventModel event) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primaryContainer,
                  image: event.coverImage != null && event.coverImage!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(event.coverImage!), fit: BoxFit.cover)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTypography.titleMedium.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.venueName} • ${event.eventDate}',
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          label: Text(event.status.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: event.status == 'verified' ? AppColors.tertiaryContainer : AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${event.goingCount} Going • ${event.confirmationsCount} Verified',
                          style: AppTypography.labelMedium.copyWith(fontSize: 11),
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
    );
  }
}
