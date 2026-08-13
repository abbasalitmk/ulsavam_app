import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../districts/providers/districts_provider.dart';
import '../domain/event_model.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

// Kerala's approximate geographic center, used as the map's fallback view
// until geo-tagged events for the selected district load.
const _keralaCenter = LatLng(10.8505, 76.2711);

const _kMapCategories = [
  MapEntry('temple', 'Temple Festivals'),
  MapEntry('church', 'Church Feasts'),
  MapEntry('dj_music', 'DJ & Music'),
  MapEntry('beach_meetup', 'Beach Meetups'),
  MapEntry('arts_culture', 'Arts & Culture'),
];

LatLng _centroid(List<EventModel> geoTaggedEvents) {
  final avgLat =
      geoTaggedEvents.map((e) => e.latitude!).reduce((a, b) => a + b) /
          geoTaggedEvents.length;
  final avgLng =
      geoTaggedEvents.map((e) => e.longitude!).reduce((a, b) => a + b) /
          geoTaggedEvents.length;
  return LatLng(avgLat, avgLng);
}

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  final _mapController = MapController();
  EventModel? _selectedEvent;
  String? _selectedCategory;
  bool _happeningNowOnly = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _focusEvent(EventModel event) {
    setState(() => _selectedEvent = event);
    if (event.latitude == null || event.longitude == null) return;
    _mapController.move(LatLng(event.latitude!, event.longitude!), 14);
  }

  void _recenter(List<EventModel> geoTagged) {
    if (geoTagged.isEmpty) {
      _mapController.move(_keralaCenter, 7);
    } else {
      _mapController.move(_centroid(geoTagged), 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final districtSlug = ref.watch(selectedDistrictSlugProvider);
    final filter = EventsFilter(district: districtSlug);
    final eventsAsync = ref.watch(mapEventsProvider(filter));
    final happeningNowAsync = ref.watch(happeningNowEventsProvider);
    final liveIds =
        (happeningNowAsync.valueOrNull ?? []).map((e) => e.id).toSet();

    // Re-center the map once geo-tagged events for this district arrive.
    ref.listen(mapEventsProvider(filter), (previous, next) {
      final geoTagged = (next.valueOrNull ?? [])
          .where((e) => e.latitude != null && e.longitude != null)
          .toList();
      if (geoTagged.isEmpty) return;
      _mapController.move(_centroid(geoTagged), 12);
    });

    final allGeoTagged = (eventsAsync.valueOrNull ?? [])
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();

    final filteredEvents = allGeoTagged.where((e) {
      if (_selectedCategory != null && e.category != _selectedCategory) {
        return false;
      }
      if (_happeningNowOnly && !liveIds.contains(e.id)) return false;
      return true;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _keralaCenter,
              initialZoom: 7,
              onTap: (_, __) => setState(() => _selectedEvent = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.ulsavam.ulsavam_app',
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                  TextSourceAttribution('CARTO'),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (final event in filteredEvents)
                    Marker(
                      point: LatLng(event.latitude!, event.longitude!),
                      width: liveIds.contains(event.id) ? 56 : 40,
                      height: liveIds.contains(event.id) ? 70 : 44,
                      alignment: Alignment.topCenter,
                      child: _MapMarker(
                        event: event,
                        isLive: liveIds.contains(event.id),
                        isSelected: _selectedEvent?.id == event.id,
                        onTap: () => _focusEvent(event),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Top filter pills
          SafeArea(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  _MapFilterChip(
                    label: 'All',
                    selected: _selectedCategory == null && !_happeningNowOnly,
                    onTap: () => setState(() {
                      _selectedCategory = null;
                      _happeningNowOnly = false;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _MapFilterChip(
                    label: 'Happening Now',
                    selected: _happeningNowOnly,
                    onTap: () => setState(
                        () => _happeningNowOnly = !_happeningNowOnly),
                  ),
                  for (final c in _kMapCategories) ...[
                    const SizedBox(width: 8),
                    _MapFilterChip(
                      label: c.value,
                      selected: _selectedCategory == c.key,
                      onTap: () => setState(() => _selectedCategory =
                          _selectedCategory == c.key ? null : c.key),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Recenter control
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 56,
            child: _MapIconButton(
              icon: Icons.my_location_rounded,
              onTap: () => _recenter(allGeoTagged),
            ),
          ),

          if (eventsAsync.isLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 0,
              right: 0,
              child: const Center(child: _MapLoadingChip()),
            ),

          // Bottom peek-up card for the selected marker
          if (_selectedEvent != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _EventPeekCard(
                event: _selectedEvent!,
                onClose: () => setState(() => _selectedEvent = null),
                onViewDetails: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            EventDetailScreen(eventId: _selectedEvent!.id)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MapFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MapFilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            fontSize: 12,
            color: selected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _MapLoadingChip extends StatelessWidget {
  const _MapLoadingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Text('Locating events…',
              style: AppTypography.labelMedium.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final EventModel event;
  final bool isLive;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapMarker({
    required this.event,
    required this.isLive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.secondary : AppColors.primary;

    if (!isLive) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
            ],
          ),
          child: Icon(Icons.location_on, color: color, size: 16),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.festival,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('LIVE',
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EventPeekCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const _EventPeekCard({
    required this.event,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 72,
                  height: 72,
                  color: AppColors.primaryContainer,
                  child: event.coverImage != null &&
                          event.coverImage!.isNotEmpty
                      ? Image.network(event.coverImage!, fit: BoxFit.cover)
                      : const Icon(Icons.festival, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTypography.titleMedium.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            event.venueName,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to view details',
                      style: AppTypography.labelMedium
                          .copyWith(fontSize: 11, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
