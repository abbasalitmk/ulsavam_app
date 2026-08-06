import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(exploreEventsProvider({'search': _searchQuery}));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: const InputDecoration(
            hintText: 'Search poorams, DJ nights, venues...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 64, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text('Type to search Kerala events & festivals', style: AppTypography.bodySmall),
                ],
              ),
            )
          : searchResultsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('No matching events found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event.title, style: AppTypography.titleMedium.copyWith(fontSize: 16)),
                      subtitle: Text('${event.districtName} • ${event.venueName}'),
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
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
    );
  }
}
