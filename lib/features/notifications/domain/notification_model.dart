class NotificationModel {
  final int id;
  final String type;
  final String message;
  final int? relatedEventId;
  final String? eventTitle;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    this.relatedEventId,
    this.eventTitle,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      relatedEventId: json['related_event'],
      eventTitle: json['event_title'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}
