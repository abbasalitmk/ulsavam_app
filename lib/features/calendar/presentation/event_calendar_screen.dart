import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/skeletons.dart';
import '../../../core/widgets/event_cards.dart';
import '../../districts/providers/districts_provider.dart';
import '../../events/providers/events_provider.dart';

String _formatDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class EventCalendarScreen extends ConsumerStatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  ConsumerState<EventCalendarScreen> createState() =>
      _EventCalendarScreenState();
}

class _EventCalendarScreenState extends ConsumerState<EventCalendarScreen> {
  bool _isGridView = false;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDay = DateTime(today.year, today.month, today.day);
    _focusedDay = _selectedDay;
  }

  bool get _isToday => isSameDay(_selectedDay, DateTime.now());

  void _jumpToToday() {
    final today = DateTime.now();
    setState(() {
      _selectedDay = DateTime(today.year, today.month, today.day);
      _focusedDay = _selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final districtName = ref.watch(selectedDistrictNameProvider);
    final districtSlug = ref.watch(selectedDistrictSlugProvider);
    final selectedDateStr = _formatDate(_selectedDay);
    final filter = EventsFilter(district: districtSlug, date: selectedDateStr);
    final eventsAsync = ref.watch(exploreEventsProvider(filter));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kerala Event Calendar',
            style: AppTypography.titleMedium.copyWith(fontSize: 18)),
        actions: [
          if (!_isToday)
            TextButton(
              onPressed: _jumpToToday,
              child: Text('Today',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.primary)),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ViewToggle(
              isGridView: _isGridView,
              onChanged: (val) => setState(() => _isGridView = val),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(_focusedDay.year - 1, 1, 1),
              lastDay: DateTime(_focusedDay.year + 1, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) => _focusedDay = focused,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTypography.labelMedium
                    .copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                weekendStyle: AppTypography.labelMedium
                    .copyWith(fontSize: 11, color: AppColors.primary),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    AppTypography.titleMedium.copyWith(fontSize: 16),
                leftChevronIcon: const Icon(Icons.chevron_left_rounded,
                    color: AppColors.onSurfaceVariant),
                rightChevronIcon: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: AppTypography.bodySmall
                    .copyWith(color: AppColors.onSurface, fontSize: 14),
                weekendTextStyle: AppTypography.bodySmall
                    .copyWith(color: AppColors.primary, fontSize: 14),
                todayDecoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurface, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                selectedTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Icon(Icons.event_note_rounded,
                    size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Events on ${_isToday ? "Today" : selectedDateStr} in $districtName',
                    style: AppTypography.titleMedium.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(exploreEventsProvider(filter).future),
              child: eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 320,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                        color: AppColors.surfaceContainer,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.event_busy_outlined,
                                        color: AppColors.onSurfaceVariant,
                                        size: 28),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No events scheduled for this date.',
                                    style: AppTypography.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try picking another date on the calendar.',
                                    style: AppTypography.bodySmall.copyWith(
                                        fontSize: 12, color: AppColors.outline),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (_isGridView) {
                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: events.length,
                      itemBuilder: (context, index) =>
                          EventGridDateCard(event: events[index]),
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        EventDateCard(event: events[index]),
                  );
                },
                loading: () => _isGridView
                    ? const EventGridSkeleton()
                    : const EventListSkeleton(),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.isGridView, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.view_list_rounded,
            selected: !isGridView,
            onTap: () => onChanged(false),
          ),
          _ToggleButton(
            icon: Icons.grid_view_rounded,
            selected: isGridView,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton(
      {required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              selected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ]
              : null,
        ),
        child: Icon(icon,
            size: 16,
            color: selected ? AppColors.primary : AppColors.onSurfaceVariant),
      ),
    );
  }
}
