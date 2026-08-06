class UserModel {
  final int id;
  final String? phoneNumber;
  final String? email;
  final String displayName;
  final String? avatar;
  final int? districtId;
  final String? districtName;
  final bool isInfoRevealed;
  final String preferredLanguage;

  UserModel({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.displayName,
    this.avatar,
    this.districtId,
    this.districtName,
    required this.isInfoRevealed,
    required this.preferredLanguage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      displayName: json['display_name'] ?? 'Festival Goer',
      avatar: json['avatar'],
      districtId: json['district'],
      districtName: json['district_details'] != null ? json['district_details']['name'] : null,
      isInfoRevealed: json['is_info_revealed'] ?? false,
      preferredLanguage: json['preferred_language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'avatar': avatar,
      'district': districtId,
      'is_info_revealed': isInfoRevealed,
      'preferred_language': preferredLanguage,
    };
  }
}
