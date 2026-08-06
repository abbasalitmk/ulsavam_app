import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/district_model.dart';

class DistrictsRepository {
  final ApiClient apiClient;

  DistrictsRepository({required this.apiClient});

  Future<List<DistrictModel>> getDistricts() async {
    final response = await apiClient.dio.get(ApiEndpoints.districts);
    final List list = response.data;
    return list.map((item) => DistrictModel.fromJson(item)).toList();
  }
}
