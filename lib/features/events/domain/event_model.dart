class EventModel {
  final int id;
  final String title;
  final String? description;
  final String category;
  final int districtId;
  final String districtName;
  final String districtSlug;
  final String venueName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String eventDate;
  final String? startTime;
  final String? coverImage;
  final String status;
  final bool isFeatured;
  final int confirmationsCount;
  final int goingCount;
  final bool isGoing;
  final bool isConfirmedByUser;
  final String? organizerName;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.districtId,
    required this.districtName,
    required this.districtSlug,
    required this.venueName,
    this.address,
    this.latitude,
    this.longitude,
    required this.eventDate,
    this.startTime,
    this.coverImage,
    required this.status,
    required this.isFeatured,
    required this.confirmationsCount,
    required this.goingCount,
    required this.isGoing,
    required this.isConfirmedByUser,
    this.organizerName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'community',
      districtId: json['district'] is int
          ? json['district']
          : (json['district_details']?['id'] ?? 0),
      districtName: json['district_name'] ??
          json['district_details']?['name'] ??
          'Kerala',
      districtSlug: json['district_slug'] ??
          json['district_details']?['slug'] ??
          'kerala',
      venueName: json['venue_name'] ?? '',
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      eventDate: json['event_date'] ?? '',
      startTime: json['start_time'],
      coverImage: json['cover_image'],
      status: json['status'] ?? 'pending',
      isFeatured: json['is_featured'] ?? false,
      confirmationsCount: json['confirmations_count'] ?? 0,
      goingCount: json['going_count'] ?? 0,
      isGoing: json['is_going'] ?? false,
      isConfirmedByUser: json['is_confirmed_by_user'] ?? false,
      organizerName: json['organizer_name'],
    );
  }

  EventModel copyWith({
    int? confirmationsCount,
    int? goingCount,
    bool? isGoing,
    bool? isConfirmedByUser,
    String? status,
  }) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      category: category,
      districtId: districtId,
      districtName: districtName,
      districtSlug: districtSlug,
      venueName: venueName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      eventDate: eventDate,
      startTime: startTime,
      coverImage: coverImage,
      status: status ?? this.status,
      isFeatured: isFeatured,
      confirmationsCount: confirmationsCount ?? this.confirmationsCount,
      goingCount: goingCount ?? this.goingCount,
      isGoing: isGoing ?? this.isGoing,
      isConfirmedByUser: isConfirmedByUser ?? this.isConfirmedByUser,
      organizerName: organizerName,
    );
  }
}
