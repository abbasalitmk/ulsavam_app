import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/skeletons.dart';
import '../providers/events_provider.dart';

class AttendeesScreen extends ConsumerWidget {
  final int eventId;

  const AttendeesScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendeesAsync = ref.watch(eventAttendeesProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendee List', style: AppTypography.titleMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(eventAttendeesProvider(eventId).future),
        child: attendeesAsync.when(
          data: (attendees) {
            if (attendees.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 300,
                    child:
                        Center(child: Text('No attendees marked Going yet.')),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: attendees.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final attendee = attendees[index];
                final isAnonymous =
                    attendee.displayName == 'Anonymous Festival Goer';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAnonymous
                        ? AppColors.surfaceContainerHigh
                        : AppColors.primaryContainer,
                    backgroundImage:
                        attendee.avatar != null && attendee.avatar!.isNotEmpty
                            ? NetworkImage(attendee.avatar!)
                            : null,
                    child: isAnonymous
                        ? const Icon(Icons.person_off,
                            color: AppColors.onSurfaceVariant)
                        : Text(attendee.displayName[0],
                            style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                    attendee.displayName,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight:
                          isAnonymous ? FontWeight.normal : FontWeight.bold,
                      fontStyle:
                          isAnonymous ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  subtitle: Text(
                    isAnonymous ? 'Privacy Shield Enabled' : 'Marked Going',
                    style: AppTypography.bodySmall.copyWith(fontSize: 12),
                  ),
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
                child: Center(child: Text('Error loading attendees: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
