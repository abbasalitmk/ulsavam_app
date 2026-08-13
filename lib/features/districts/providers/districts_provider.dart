import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/districts_repository.dart';
import '../domain/district_model.dart';

final districtsRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DistrictsRepository(apiClient: apiClient);
});

final districtsListProvider = FutureProvider<List<DistrictModel>>((ref) async {
  final repo = ref.watch(districtsRepositoryProvider);
  return await repo.getDistricts();
});

final selectedDistrictSlugProvider =
    StateProvider<String>((ref) => 'kozhikode');
final selectedDistrictNameProvider =
    StateProvider<String>((ref) => 'Kozhikode');
