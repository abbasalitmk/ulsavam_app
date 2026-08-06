import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/notifications_repository.dart';
import '../domain/notification_model.dart';
import '../../events/presentation/event_detail_screen.dart';

final notificationsRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationsRepository(apiClient: apiClient);
});

final notificationsListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repo = ref.watch(notificationsRepositoryProvider);
  return await repo.getNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.titleMedium),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                tileColor: notif.isRead ? Colors.transparent : AppColors.surfaceContainer,
                leading: CircleAvatar(
                  backgroundColor: notif.type == 'confirmation_added'
                      ? AppColors.tertiaryContainer
                      : AppColors.secondaryContainer,
                  child: Icon(
                    notif.type == 'confirmation_added' ? Icons.verified : Icons.notifications,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(notif.message, style: AppTypography.bodyLarge.copyWith(fontSize: 14)),
                subtitle: Text(notif.createdAt, style: AppTypography.labelMedium.copyWith(fontSize: 10)),
                onTap: () {
                  if (notif.relatedEventId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: notif.relatedEventId!)),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
