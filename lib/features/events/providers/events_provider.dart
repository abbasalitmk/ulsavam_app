import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../districts/providers/districts_provider.dart';
import '../data/events_repository.dart';
import '../domain/event_model.dart';
import '../domain/attendee_model.dart';

class EventsFilter {
  final String? district;
  final String? date;
  final String? category;
  final bool? verifiedOnly;
  final String? search;

  const EventsFilter({
    this.district,
    this.date,
    this.category,
    this.verifiedOnly,
    this.search,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EventsFilter &&
            district == other.district &&
            date == other.date &&
            category == other.category &&
            verifiedOnly == other.verifiedOnly &&
            search == other.search;
  }

  @override
  int get hashCode =>
      Object.hash(district, date, category, verifiedOnly, search);
}

final eventsRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventsRepository(apiClient: apiClient);
});

final happeningNowEventsProvider =
    FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.watch(eventsRepositoryProvider);
  final districtSlug = ref.watch(selectedDistrictSlugProvider);
  return await repo.getHappeningNow(districtSlug: districtSlug);
});

final exploreEventsProvider =
    FutureProvider.family<List<EventModel>, EventsFilter>((ref, filter) async {
  final repo = ref.watch(eventsRepositoryProvider);
  return await repo.getEvents(
    districtSlug: filter.district,
    date: filter.date,
    category: filter.category,
    verifiedOnly: filter.verifiedOnly,
    search: filter.search,
  );
});

// The events list endpoint doesn't return per-event coordinates (only the
// detail endpoint does), so the map view fetches full details for each
// filtered event in parallel to back-fill latitude/longitude for markers.
final mapEventsProvider =
    FutureProvider.family<List<EventModel>, EventsFilter>((ref, filter) async {
  final repo = ref.watch(eventsRepositoryProvider);
  final events = await repo.getEvents(
    districtSlug: filter.district,
    date: filter.date,
    category: filter.category,
    verifiedOnly: filter.verifiedOnly,
    search: filter.search,
  );
  return await Future.wait(events.map((e) => repo.getEventDetail(e.id)));
});

final eventDetailProvider =
    FutureProvider.family<EventModel, int>((ref, id) async {
  final repo = ref.watch(eventsRepositoryProvider);
  return await repo.getEventDetail(id);
});

final eventAttendeesProvider =
    FutureProvider.family<List<AttendeeModel>, int>((ref, eventId) async {
  final repo = ref.watch(eventsRepositoryProvider);
  return await repo.getAttendees(eventId);
});
