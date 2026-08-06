class DistrictModel {
  final int id;
  final String name;
  final String slug;

  DistrictModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}
