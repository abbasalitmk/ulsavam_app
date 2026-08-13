import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/event_model.dart';
import '../domain/attendee_model.dart';

class EventsRepository {
  final ApiClient apiClient;

  EventsRepository({required this.apiClient});

  Future<List<EventModel>> getEvents({
    String? districtSlug,
    String? date,
    String? category,
    bool? verifiedOnly,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (districtSlug != null && districtSlug.isNotEmpty)
      queryParams['district'] = districtSlug;
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (verifiedOnly != null)
      queryParams['verified_only'] = verifiedOnly.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await apiClient.dio
        .get(ApiEndpoints.events, queryParameters: queryParams);
    final List results = response.data['results'] ?? response.data;
    return results.map((item) => EventModel.fromJson(item)).toList();
  }

  Future<List<EventModel>> getHappeningNow({String? districtSlug}) async {
    final queryParams = <String, dynamic>{};
    if (districtSlug != null && districtSlug.isNotEmpty)
      queryParams['district'] = districtSlug;

    final response = await apiClient.dio
        .get(ApiEndpoints.happeningNow, queryParameters: queryParams);
    final List results = response.data;
    return results.map((item) => EventModel.fromJson(item)).toList();
  }

  Future<EventModel> getEventDetail(int id) async {
    final response = await apiClient.dio.get(ApiEndpoints.eventDetail(id));
    return EventModel.fromJson(response.data);
  }

  Future<EventModel> createEvent(Map<String, dynamic> data) async {
    final response = await apiClient.dio.post(ApiEndpoints.events, data: data);
    return EventModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> toggleGoing(int eventId) async {
    final response = await apiClient.dio.post(ApiEndpoints.eventGoing(eventId));
    return response.data;
  }

  Future<Map<String, dynamic>> confirmEvent(int eventId) async {
    final response =
        await apiClient.dio.post(ApiEndpoints.eventConfirm(eventId));
    return response.data;
  }

  Future<List<AttendeeModel>> getAttendees(int eventId) async {
    final response =
        await apiClient.dio.get(ApiEndpoints.eventAttendees(eventId));
    final List results = response.data;
    return results.map((item) => AttendeeModel.fromJson(item)).toList();
  }
}
