class AttendeeModel {
  final int id;
  final int userId;
  final String displayName;
  final String? avatar;
  final String createdAt;

  AttendeeModel({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatar,
    required this.createdAt,
  });

  factory AttendeeModel.fromJson(Map<String, dynamic> json) {
    return AttendeeModel(
      id: json['id'],
      userId: json['user_id'],
      displayName: json['display_name'] ?? 'Anonymous Festival Goer',
      avatar: json['avatar'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
