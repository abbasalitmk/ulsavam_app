import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/districts_provider.dart';
import '../../events/presentation/home_screen.dart';

class DistrictPickerScreen extends ConsumerStatefulWidget {
  const DistrictPickerScreen({super.key});

  @override
  ConsumerState<DistrictPickerScreen> createState() => _DistrictPickerScreenState();
}

class _DistrictPickerScreenState extends ConsumerState<DistrictPickerScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select District', style: AppTypography.titleMedium),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search Kerala district...',
                prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
              ),
            ),
          ),
          Expanded(
            child: districtsAsync.when(
              data: (districts) {
                final filtered = districts
                    .where((d) => d.name.toLowerCase().contains(_searchQuery))
                    .toList();

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final district = filtered[index];
                    final isSelected = ref.watch(selectedDistrictSlugProvider) == district.slug;

                    return ListTile(
                      title: Text(
                        district.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primary)
                          : const Icon(Icons.chevron_right, color: AppColors.outline),
                      onTap: () {
                        ref.read(selectedDistrictNameProvider.notifier).state = district.name;
                        ref.read(selectedDistrictSlugProvider.notifier).state = district.slug;

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading districts: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
