import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/notification_model.dart';

class NotificationsRepository {
  final ApiClient apiClient;

  NotificationsRepository({required this.apiClient});

  Future<List<NotificationModel>> getNotifications() async {
    final response = await apiClient.dio.get(ApiEndpoints.notifications);
    final List results = response.data['results'] ?? response.data;
    return results.map((item) => NotificationModel.fromJson(item)).toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await apiClient.dio.post(ApiEndpoints.notificationRead(notificationId));
  }
}
