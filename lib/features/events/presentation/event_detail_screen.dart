import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/skeletons.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../providers/events_provider.dart';
import '../domain/event_model.dart';
import 'verify_confirmation_sheet.dart';
import 'attendees_screen.dart';

String _categoryLabel(String slug) {
  switch (slug) {
    case 'temple':
      return 'Temple Pooram';
    case 'church':
      return 'Church Feast';
    case 'dj_music':
      return 'DJ & Music';
    case 'beach_meetup':
      return 'Beach Meetup';
    case 'arts_culture':
      return 'Arts & Culture';
    default:
      return slug;
  }
}

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isTogglingGoing = false;
  bool _descriptionExpanded = false;

  Future<void> _toggleGoing(EventModel event) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
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

  Future<void> _openDirections(EventModel event) async {
    final Uri uri;
    if (event.latitude != null && event.longitude != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}');
    } else {
      final query = Uri.encodeComponent(
          '${event.venueName}, ${event.address ?? event.districtName}');
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps for directions.')),
      );
    }
  }

  void _openVerifySheet(EventModel event) {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        elevation: 0,
        title: Text('Event Detail',
            style: AppTypography.titleMedium.copyWith(fontSize: 18)),
      ),
      body: eventAsync.when(
        data: (event) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(eventDetailProvider(widget.eventId).future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(event: event),
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: AppTypography.headlineLarge),
                          const SizedBox(height: 4),
                          Text(
                            _categoryLabel(event.category),
                            style: AppTypography.titleMedium.copyWith(
                                fontSize: 16, color: AppColors.secondary),
                          ),
                          const SizedBox(height: 16),
                          _DateTimeRow(event: event),
                          const SizedBox(height: 20),

                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child: _GoingButton(
                                  isGoing: event.isGoing,
                                  goingCount: event.goingCount,
                                  loading: _isTogglingGoing,
                                  onTap: () => _toggleGoing(event),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: event.isConfirmedByUser
                                      ? null
                                      : () => _openVerifySheet(event),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor:
                                        AppColors.surfaceContainerHigh,
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  icon: Icon(
                                    event.isConfirmedByUser
                                        ? Icons.check
                                        : Icons.verified_outlined,
                                    color: event.isConfirmedByUser
                                        ? AppColors.onSurfaceVariant
                                        : Colors.white,
                                  ),
                                  label: Text(
                                    event.isConfirmedByUser
                                        ? 'Verified'
                                        : 'Verify Event',
                                    style: TextStyle(
                                      color: event.isConfirmedByUser
                                          ? AppColors.onSurfaceVariant
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Organizer + Location combined card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.badge_outlined,
                                          color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Organized by',
                                              style: AppTypography.bodySmall),
                                          Text(
                                            event.organizerName
                                                        ?.isNotEmpty ==
                                                    true
                                                ? event.organizerName!
                                                : 'Community Organizer',
                                            style: AppTypography.titleMedium
                                                .copyWith(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: AppColors.secondary, size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(event.venueName,
                                              style: AppTypography.bodyLarge
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                          Text(
                                            [
                                              if (event.address != null &&
                                                  event.address!.isNotEmpty)
                                                event.address,
                                              '${event.districtName} District',
                                            ].join(', '),
                                            style: AppTypography.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (event.latitude != null &&
                                    event.longitude != null) ...[
                                  const SizedBox(height: 12),
                                  _LocationPreviewMap(event: event),
                                ],
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openDirections(event),
                                    icon: const Icon(Icons.directions_rounded,
                                        size: 18),
                                    label: const Text('Get Directions'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      minimumSize: const Size.fromHeight(46),
                                      side: BorderSide(
                                          color: AppColors.primary
                                              .withOpacity(0.35),
                                          width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Description
                          Text('About the event',
                              style: AppTypography.titleMedium),
                          const SizedBox(height: 10),
                          Text(
                            event.description ?? 'No description provided.',
                            maxLines: _descriptionExpanded ? null : 4,
                            overflow: _descriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: AppTypography.bodyLarge
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          if ((event.description ?? '').length > 160)
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => setState(() =>
                                  _descriptionExpanded = !_descriptionExpanded),
                              child: Text(
                                  _descriptionExpanded
                                      ? 'Show less'
                                      : 'Read more',
                                  style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                            ),

                          const SizedBox(height: 16),

                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Tag(label: _categoryLabel(event.category)),
                              _Tag(
                                  label: event.status == 'verified'
                                      ? 'Verified'
                                      : 'Pending Verification'),
                            ],
                          ),

                          const SizedBox(height: 28),
                          const Divider(),
                          const SizedBox(height: 12),

                          // Attendees entry
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AttendeesScreen(eventId: event.id)),
                              );
                            },
                            child: Row(
                              children: [
                                Text('Who is Attending',
                                    style: AppTypography.titleMedium
                                        .copyWith(fontSize: 16)),
                                const Spacer(),
                                Text('${event.goingCount} People',
                                    style: AppTypography.labelMedium
                                        .copyWith(color: AppColors.primary)),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Related events
                  _RelatedEventsSection(currentEvent: event),
                ],
              ),
            ),
          );
        },
        loading: () => const EventDetailSkeleton(),
        error: (err, _) =>
            Center(child: Text('Error loading event detail: $err')),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final EventModel event;

  const _HeroSection({required this.event});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: AppColors.primaryContainer,
            child: event.coverImage != null && event.coverImage!.isNotEmpty
                ? Image.network(event.coverImage!, fit: BoxFit.cover)
                : const Icon(Icons.festival, color: Colors.white, size: 56),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.surface.withOpacity(0.5),
                  AppColors.surface,
                ],
                stops: const [0.3, 0.75, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Row(
              children: [
                if (event.status == 'verified')
                  _HeroBadge(
                    icon: Icons.check_circle,
                    label: 'Verified',
                    color: AppColors.tertiaryContainer,
                    textColor: Colors.white,
                  ),
                const SizedBox(width: 8),
                _HeroBadge(
                  icon: Icons.groups_rounded,
                  label: '${event.goingCount} Going',
                  color: Colors.white.withOpacity(0.92),
                  textColor: AppColors.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _HeroBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(fontSize: 11, color: textColor)),
        ],
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  final EventModel event;

  const _DateTimeRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(event.eventDate);
    final dateLabel = parsed != null
        ? DateFormat('EEEE, MMMM d').format(parsed)
        : event.eventDate;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today_rounded,
              color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel,
                style: AppTypography.bodyLarge
                    .copyWith(fontWeight: FontWeight.w600)),
            Text(event.startTime ?? 'All Day', style: AppTypography.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _GoingButton extends StatelessWidget {
  final bool isGoing;
  final int goingCount;
  final bool loading;
  final VoidCallback onTap;

  const _GoingButton({
    required this.isGoing,
    required this.goingCount,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isGoing
            ? AppColors.tertiaryContainer
            : AppColors.surfaceContainerHigh,
        foregroundColor: isGoing ? Colors.white : AppColors.onSurface,
        minimumSize: const Size.fromHeight(48),
        elevation: 0,
      ),
      icon: Icon(isGoing ? Icons.favorite : Icons.favorite_border, size: 18),
      label: Text(isGoing ? 'Going ($goingCount)' : "I'm Going"),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Text(label,
          style: AppTypography.labelMedium
              .copyWith(fontSize: 12, color: AppColors.onSurface)),
    );
  }
}

class _LocationPreviewMap extends StatelessWidget {
  final EventModel event;

  const _LocationPreviewMap({required this.event});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(event.latitude!, event.longitude!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 130,
        child: IgnorePointer(
          child: FlutterMap(
            options: MapOptions(initialCenter: point, initialZoom: 13.5),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.ulsavam.ulsavam_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 34,
                    height: 34,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on,
                        color: AppColors.primary, size: 34),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatedEventsSection extends ConsumerWidget {
  final EventModel currentEvent;

  const _RelatedEventsSection({required this.currentEvent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = EventsFilter(district: currentEvent.districtSlug);
    final relatedAsync = ref.watch(exploreEventsProvider(filter));

    return relatedAsync.when(
      data: (events) {
        final related =
            events.where((e) => e.id != currentEvent.id).take(6).toList();
        if (related.isEmpty) return const SizedBox();

        return Container(
          color: AppColors.surfaceContainerLowest,
          padding: const EdgeInsets.only(top: 24, bottom: 32, left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You might also like', style: AppTypography.titleMedium),
              const SizedBox(height: 14),
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 20),
                  itemCount: related.length,
                  itemBuilder: (context, index) =>
                      _RelatedEventCard(event: related[index]),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _RelatedEventCard extends StatelessWidget {
  final EventModel event;

  const _RelatedEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(event.eventDate);
    final dateLabel =
        parsed != null ? DateFormat('E, MMM d').format(parsed) : event.eventDate;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id)),
        );
      },
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: Container(
                color: AppColors.primaryContainer,
                child: event.coverImage != null && event.coverImage!.isNotEmpty
                    ? Image.network(event.coverImage!, fit: BoxFit.cover)
                    : const Icon(Icons.festival, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateLabel,
                      style: AppTypography.labelMedium
                          .copyWith(fontSize: 10.5, color: AppColors.secondary)),
                  const SizedBox(height: 2),
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(fontSize: 14),
                  ),
                  Text(
                    event.venueName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(fontSize: 11.5),
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
