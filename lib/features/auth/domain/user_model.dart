class UserModel {
  final int id;
  final String? phoneNumber;
  final String? email;
  final String displayName;
  final String? avatar;
  final String? profilePicUrl;
  final String? dateOfBirth;
  final String? gender;
  final int? districtId;
  final String? districtName;
  final String? districtSlug;
  final bool isInfoRevealed;
  final String preferredLanguage;

  UserModel({
    required this.id,
    this.phoneNumber,
    this.email,
    required this.displayName,
    this.avatar,
    this.profilePicUrl,
    this.dateOfBirth,
    this.gender,
    this.districtId,
    this.districtName,
    this.districtSlug,
    required this.isInfoRevealed,
    required this.preferredLanguage,
  });

  /// Prefers the uploaded profile picture, falling back to the legacy
  /// external `avatar` URL when no upload exists.
  String? get displayImageUrl => profilePicUrl ?? avatar;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      displayName: json['display_name'] ?? 'Festival Goer',
      avatar: json['avatar'],
      profilePicUrl: json['profile_pic_url'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      districtId: json['district'],
      districtName: json['district_details'] != null
          ? json['district_details']['name']
          : null,
      districtSlug: json['district_details'] != null
          ? json['district_details']['slug']
          : null,
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
