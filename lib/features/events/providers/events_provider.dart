import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../districts/providers/districts_provider.dart';
import '../data/events_repository.dart';
import '../domain/event_model.dart';
import '../domain/attendee_model.dart';

final eventsRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventsRepository(apiClient: apiClient);
});

final happeningNowEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.watch(eventsRepositoryProvider);
  final districtSlug = ref.watch(selectedDistrictSlugProvider);
  return await repo.getHappeningNow(districtSlug: districtSlug);
});

final exploreEventsProvider = FutureProvider.family<List<EventModel>, Map<String, dynamic>>((ref, params) async {
  final repo = ref.watch(eventsRepositoryProvider);
  return await repo.getEvents(
    districtSlug: params['district'],
    date: params['date'],
    category: params['category'],
    verifiedOnly: params['verified_only'],
    search: params['search'],
  );
});

final calendarEventsProvider = FutureProvider.family<List<EventModel>, String>((ref, month) async {
  final repo = ref.watch(eventsRepositoryProvider);
  final districtSlug = ref.watch(selectedDistrictSlugProvider);
  return await repo.getCalendarEvents(districtSlug: districtSlug, month: month);
});

final eventDetailProvider = FutureProvider.family<EventModel, int>((ref, id) async {
  final repo = ref.watch(eventsRepositoryProvider);
  return await repo.getEventDetail(id);
});

final eventAttendeesProvider = FutureProvider.family<List<AttendeeModel>, int>((ref, eventId) async {
  final repo = ref.watch(eventsRepositoryProvider);
  return await repo.getAttendees(eventId);
});
