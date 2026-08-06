import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../providers/events_provider.dart';
import '../domain/event_model.dart';
import 'verify_confirmation_sheet.dart';
import 'attendees_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isTogglingGoing = false;

  Future<void> _toggleGoing(EventModel event) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    setState(() => _isTogglingGoing = true);
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final res = await repo.toggleGoing(event.id);
      ref.invalidate(eventDetailProvider(widget.eventId));
      ref.invalidate(happeningNowEventsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Status updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update Going status.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingGoing = false);
    }
  }

  void _openVerifySheet(EventModel event) {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerifyConfirmationSheet(event: event),
    ).then((_) {
      ref.invalidate(eventDetailProvider(widget.eventId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: eventAsync.when(
        data: (event) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(color: Colors.white),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AppColors.primaryContainer,
                        child: event.coverImage != null && event.coverImage!.isNotEmpty
                            ? Image.network(event.coverImage!, fit: BoxFit.cover)
                            : null,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Verification Badge Bar
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: event.status == 'verified' ? AppColors.tertiaryContainer : AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  event.status == 'verified' ? Icons.verified : Icons.hourglass_empty,
                                  size: 16,
                                  color: event.status == 'verified' ? Colors.white : AppColors.onSecondaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.status == 'verified'
                                      ? '${event.confirmationsCount} Community Verifications'
                                      : 'Pending (${event.confirmationsCount}/3 Verifications)',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: event.status == 'verified' ? Colors.white : AppColors.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            event.category.toUpperCase(),
                            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons: Going Toggle & Verify Event
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isTogglingGoing ? null : () => _toggleGoing(event),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: event.isGoing ? AppColors.tertiaryContainer : AppColors.primary,
                              ),
                              icon: Icon(event.isGoing ? Icons.check_circle : Icons.event_available),
                              label: Text(event.isGoing ? 'Going (${event.goingCount})' : 'Mark Going (${event.goingCount})'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: event.isConfirmedByUser ? null : () => _openVerifySheet(event),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: BorderSide(
                                  color: event.isConfirmedByUser ? AppColors.outline : AppColors.secondary,
                                  width: 1.5,
                                ),
                              ),
                              icon: Icon(
                                event.isConfirmedByUser ? Icons.check : Icons.security,
                                color: event.isConfirmedByUser ? AppColors.outline : AppColors.secondary,
                              ),
                              label: Text(
                                event.isConfirmedByUser ? 'Verified' : 'Verify Event',
                                style: AppTypography.labelMedium.copyWith(
                                  color: event.isConfirmedByUser ? AppColors.outline : AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Venue & Date Info
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceContainer,
                          child: Icon(Icons.location_on, color: AppColors.primary),
                        ),
                        title: Text(event.venueName, style: AppTypography.titleMedium.copyWith(fontSize: 16)),
                        subtitle: Text('${event.address ?? ''}\n${event.districtName} District', style: AppTypography.bodySmall),
                      ),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceContainer,
                          child: Icon(Icons.calendar_today, color: AppColors.primary),
                        ),
                        title: Text('Date & Time', style: AppTypography.titleMedium.copyWith(fontSize: 16)),
                        subtitle: Text('${event.eventDate} • ${event.startTime ?? "All Day"}', style: AppTypography.bodySmall),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Event Description
                      Text('About this Event', style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        event.description ?? 'No description provided.',
                        style: AppTypography.bodyLarge,
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Attendees List Entry
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AttendeesScreen(eventId: event.id)),
                          );
                        },
                        child: Row(
                          children: [
                            Text('Who is Attending', style: AppTypography.titleMedium),
                            const Spacer(),
                            Text('${event.goingCount} People', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                            const Icon(Icons.chevron_right, color: AppColors.primary),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading event detail: $err')),
      ),
    );
  }
}
