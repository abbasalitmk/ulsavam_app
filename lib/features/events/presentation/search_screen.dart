import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/skeletons.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _debounceDuration = Duration(milliseconds: 400);

  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      if (mounted) setState(() => _searchQuery = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = EventsFilter(search: _searchQuery);
    final searchResultsAsync =
        _searchQuery.isEmpty ? null : ref.watch(exploreEventsProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: _onQueryChanged,
          decoration: const InputDecoration(
            hintText: 'Search poorams, DJ nights, venues...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
      body: searchResultsAsync == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search, size: 64, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text('Type to search Kerala events & festivals',
                      style: AppTypography.bodySmall),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(exploreEventsProvider(filter).future),
              child: searchResultsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 300,
                          child:
                              Center(child: Text('No matching events found.')),
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(event.title,
                            style: AppTypography.titleMedium
                                .copyWith(fontSize: 16)),
                        subtitle:
                            Text('${event.districtName} • ${event.venueName}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailScreen(eventId: event.id)),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const TileListSkeleton(),
                error: (err, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 300,
                      child: Center(child: Text('Error: $err')),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
