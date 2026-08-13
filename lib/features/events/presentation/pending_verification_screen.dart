import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/skeletons.dart';
import '../../districts/providers/districts_provider.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class PendingVerificationScreen extends ConsumerWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtSlug = ref.watch(selectedDistrictSlugProvider);
    final filter = EventsFilter(district: districtSlug, verifiedOnly: false);
    final pendingAsync = ref.watch(exploreEventsProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Verifications', style: AppTypography.titleMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(exploreEventsProvider(filter).future),
        child: pendingAsync.when(
          data: (events) {
            final pendingEvents =
                events.where((e) => e.status == 'pending').toList();

            if (pendingEvents.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(
                        child:
                            Text('No pending verifications in this district.')),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: pendingEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = pendingEvents[index];
                return Card(
                  child: ListTile(
                    title: Text(event.title,
                        style:
                            AppTypography.titleMedium.copyWith(fontSize: 16)),
                    subtitle: Text(
                        'Progress: ${event.confirmationsCount}/3 Verifications'),
                    trailing:
                        const Icon(Icons.security, color: AppColors.secondary),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                EventDetailScreen(eventId: event.id)),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const EventListSkeleton(),
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
