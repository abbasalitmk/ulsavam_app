import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../districts/providers/districts_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../events/presentation/event_detail_screen.dart';

class FestivalCalendarScreen extends ConsumerStatefulWidget {
  const FestivalCalendarScreen({super.key});

  @override
  ConsumerState<FestivalCalendarScreen> createState() => _FestivalCalendarScreenState();
}

class _FestivalCalendarScreenState extends ConsumerState<FestivalCalendarScreen> {
  bool _isGridView = false;
  String _selectedMonth = '2026-08';

  @override
  Widget build(BuildContext context) {
    final districtName = ref.watch(selectedDistrictNameProvider);
    final calendarAsync = ref.watch(calendarEventsProvider(_selectedMonth));

    return Scaffold(
      appBar: AppBar(
        title: Text('Kerala Festival Calendar', style: AppTypography.titleMedium),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing events for $_selectedMonth in $districtName', style: AppTypography.bodySmall),
                DropdownButton<String>(
                  value: _selectedMonth,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '2026-08', child: Text('Aug 2026')),
                    DropdownMenuItem(value: '2026-09', child: Text('Sep 2026')),
                    DropdownMenuItem(value: '2026-10', child: Text('Oct 2026')),
                  ],
                  onChanged: (val) => setState(() => _selectedMonth = val!),
                ),
              ],
            ),
          ),

          Expanded(
            child: calendarAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('No scheduled festival calendar events for this month.'));
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                    image: event.coverImage != null && event.coverImage!.isNotEmpty
                                        ? DecorationImage(image: NetworkImage(event.coverImage!), fit: BoxFit.cover)
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(event.title, style: AppTypography.titleMedium.copyWith(fontSize: 14), maxLines: 2),
                                const Spacer(),
                                Text(event.eventDate, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: const Icon(Icons.festival, color: Colors.white),
                      ),
                      title: Text(event.title, style: AppTypography.titleMedium.copyWith(fontSize: 16)),
                      subtitle: Text('${event.venueName} • ${event.eventDate}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading calendar: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
