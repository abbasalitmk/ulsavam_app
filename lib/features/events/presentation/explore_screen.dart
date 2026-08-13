import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/skeletons.dart';
import '../../districts/providers/districts_provider.dart';
import '../../districts/presentation/district_picker_screen.dart';
import '../providers/events_provider.dart';
import '../domain/event_model.dart';
import 'event_detail_screen.dart';

class _CategoryOption {
  final String slug;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryOption(this.slug, this.label, this.icon, this.color);
}

const _kCategoryOptions = [
  _CategoryOption(
      'temple', 'Temple Festivals (Pooram)', Icons.temple_hindu, AppColors.primary),
  _CategoryOption('church', 'Church Feasts', Icons.church, AppColors.secondary),
  _CategoryOption(
      'dj_music', 'DJ & Music', Icons.music_note, AppColors.tertiary),
  _CategoryOption(
      'beach_meetup', 'Beach Meetups', Icons.beach_access, AppColors.primary),
  _CategoryOption(
      'arts_culture', 'Arts & Culture', Icons.palette, AppColors.secondary),
];

String _categoryLabel(String slug) {
  for (final c in _kCategoryOptions) {
    if (c.slug == slug) return c.label.split(' (').first;
  }
  return slug;
}

const _keralaCenter = LatLng(10.8505, 76.2711);

class ExploreScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  Set<String> _selectedCategories = {};
  DateTime? _selectedDate;
  bool _verifiedOnly = false;
  bool _isMapView = false;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategories = {widget.initialCategory!};
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<EventModel> _applyClientFilters(List<EventModel> events) {
    return events.where((e) {
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(e.category)) {
        return false;
      }
      if (_selectedDate != null) {
        final d = DateTime.tryParse(e.eventDate);
        if (d == null) return false;
        if (d.year != _selectedDate!.year ||
            d.month != _selectedDate!.month ||
            d.day != _selectedDate!.day) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _selectedCategories.isNotEmpty || _selectedDate != null || _verifiedOnly;

  void _clearFilters() {
    setState(() {
      _selectedCategories = {};
      _selectedDate = null;
      _verifiedOnly = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _openCategorySheet() async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFilterSheet(initialSelected: _selectedCategories),
    );
    if (result != null) {
      setState(() => _selectedCategories = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final districtSlug = ref.watch(selectedDistrictSlugProvider);
    final districtName = ref.watch(selectedDistrictNameProvider);
    final filter =
        EventsFilter(district: districtSlug, verifiedOnly: _verifiedOnly);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: title + list/map toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Explore', style: AppTypography.headlineLarge),
                  _ViewToggle(
                    isMapView: _isMapView,
                    onChanged: (val) => setState(() => _isMapView = val),
                  ),
                ],
              ),
            ),

            // Filter pills row
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterPill(
                    icon: Icons.location_on_outlined,
                    label: districtName,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const DistrictPickerScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    icon: Icons.calendar_today_outlined,
                    label: _selectedDate == null
                        ? 'Date'
                        : DateFormat('MMM d').format(_selectedDate!),
                    selected: _selectedDate != null,
                    onTap: _pickDate,
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    icon: Icons.theater_comedy_outlined,
                    label: _selectedCategories.isEmpty
                        ? 'Art Forms'
                        : 'Art Forms (${_selectedCategories.length})',
                    selected: _selectedCategories.isNotEmpty,
                    onTap: _openCategorySheet,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Verified toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.verified, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Verified events only', style: AppTypography.bodySmall),
                  const Spacer(),
                  Switch(
                    value: _verifiedOnly,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _verifiedOnly = val),
                  ),
                ],
              ),
            ),

            const Divider(height: 20),

            Expanded(
              child: _isMapView
                  ? _buildMapContent(filter)
                  : _buildListContent(filter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(EventsFilter filter) {
    final eventsAsync = ref.watch(exploreEventsProvider(filter));

    return RefreshIndicator(
      onRefresh: () => ref.refresh(exploreEventsProvider(filter).future),
      child: eventsAsync.when(
        data: (allEvents) {
          final events = _applyClientFilters(allEvents);
          if (events.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _EmptyState(
                  hasFilters: _hasActiveFilters,
                  onClearFilters: _clearFilters,
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) =>
                _ExploreEventCard(event: events[index]),
          );
        },
        loading: () => const EventListSkeleton(),
        error: (err, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: Center(child: Text('Error loading events: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent(EventsFilter filter) {
    final eventsAsync = ref.watch(mapEventsProvider(filter));

    return eventsAsync.when(
      data: (allEvents) {
        final events = _applyClientFilters(allEvents)
            .where((e) => e.latitude != null && e.longitude != null)
            .toList();

        LatLng center = _keralaCenter;
        double zoom = 7;
        if (events.isNotEmpty) {
          final avgLat =
              events.map((e) => e.latitude!).reduce((a, b) => a + b) /
                  events.length;
          final avgLng =
              events.map((e) => e.longitude!).reduce((a, b) => a + b) /
                  events.length;
          center = LatLng(avgLat, avgLng);
          zoom = 11;
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: center, initialZoom: zoom),
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
                    for (final event in events)
                      Marker(
                        point: LatLng(event.latitude!, event.longitude!),
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailScreen(eventId: event.id)),
                            );
                          },
                          child: const Icon(Icons.location_on,
                              color: AppColors.primary, size: 40),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (events.isEmpty)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _MapEmptyChip(hasFilters: _hasActiveFilters),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading map: $err')),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isMapView;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.isMapView, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment:
                isMapView ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 40,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 4),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onChanged(false),
                  child: Icon(Icons.view_list_rounded,
                      size: 18,
                      color: isMapView
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface),
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onChanged(true),
                  child: Icon(Icons.map_rounded,
                      size: 18,
                      color: isMapView
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer.withOpacity(0.12)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontSize: 12,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreEventCard extends StatelessWidget {
  final EventModel event;

  const _ExploreEventCard({required this.event});

  bool get _isToday {
    final d = DateTime.tryParse(event.eventDate);
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(event.eventDate);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.primaryContainer,
                    child: event.coverImage != null &&
                            event.coverImage!.isNotEmpty
                        ? Image.network(event.coverImage!, fit: BoxFit.cover)
                        : Icon(Icons.festival,
                            color: Colors.white.withOpacity(0.8), size: 40),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.35),
                        ],
                      ),
                    ),
                  ),
                  if (event.status == 'verified')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified,
                                size: 12, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text('VERIFIED',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _categoryLabel(event.category).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(
                              fontSize: 16, height: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${event.venueName}, ${event.districtName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall
                                    .copyWith(fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isToday
                          ? AppColors.errorContainer.withOpacity(0.5)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: _isToday
                          ? Border.all(
                              color: AppColors.errorContainer, width: 1)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          parsedDate != null
                              ? DateFormat('MMM').format(parsedDate).toUpperCase()
                              : '',
                          style: AppTypography.labelMedium.copyWith(
                            fontSize: 10,
                            color: _isToday
                                ? AppColors.error
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          parsedDate != null ? '${parsedDate.day}' : '-',
                          style: AppTypography.headlineLarge.copyWith(
                            fontSize: 20,
                            height: 1,
                            color: _isToday
                                ? AppColors.error
                                : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
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

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({required this.hasFilters, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                color: AppColors.outline, size: 42),
          ),
          const SizedBox(height: 20),
          Text('No events found',
              style: AppTypography.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? "Even our elephants couldn't find a match for these exact filters. Try broadening your search."
                : 'No events are listed here yet. Check back soon.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onClearFilters,
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapEmptyChip extends StatelessWidget {
  final bool hasFilters;

  const _MapEmptyChip({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Text(
        hasFilters
            ? 'No geo-tagged events match your filters.'
            : 'No geo-tagged events in this district yet.',
        style: AppTypography.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CategoryFilterSheet extends StatefulWidget {
  final Set<String> initialSelected;

  const _CategoryFilterSheet({required this.initialSelected});

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  late Set<String> _local;

  @override
  void initState() {
    super.initState();
    _local = Set.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Art Forms & Categories',
                      style: AppTypography.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final option in _kCategoryOptions)
                    _CategoryCheckRow(
                      option: option,
                      checked: _local.contains(option.slug),
                      onTap: () {
                        setState(() {
                          if (_local.contains(option.slug)) {
                            _local.remove(option.slug);
                          } else {
                            _local.add(option.slug);
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.surfaceContainer, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _local = {}),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_local),
                      child: const Text('Show Results'),
                    ),
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

class _CategoryCheckRow extends StatelessWidget {
  final _CategoryOption option;
  final bool checked;
  final VoidCallback onTap;

  const _CategoryCheckRow({
    required this.option,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: option.color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(option.icon, color: option.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(option.label, style: AppTypography.bodyLarge),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: checked ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: checked
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
