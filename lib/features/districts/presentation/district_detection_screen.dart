import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/location/location_service.dart';
import '../providers/districts_provider.dart';
import 'district_picker_screen.dart';
import '../../shell/presentation/main_shell.dart';

class DistrictDetectionScreen extends ConsumerStatefulWidget {
  const DistrictDetectionScreen({super.key});

  @override
  ConsumerState<DistrictDetectionScreen> createState() =>
      _DistrictDetectionScreenState();
}

class _DistrictDetectionScreenState
    extends ConsumerState<DistrictDetectionScreen> {
  bool _isDetecting = false;
  final _locationService = LocationService();

  Future<void> _detectLocation() async {
    setState(() => _isDetecting = true);
    final detectedDistrict = await _locationService.detectDistrictName();
    setState(() => _isDetecting = false);

    if (detectedDistrict != null) {
      ref.read(selectedDistrictNameProvider.notifier).state = detectedDistrict;
      ref.read(selectedDistrictSlugProvider.notifier).state =
          detectedDistrict.toLowerCase();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.my_location,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Where are you located?',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Ulsavam shows hyperlocal temple poorams, concerts & meetups in your district.',
                style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isDetecting ? null : _detectLocation,
                icon: _isDetecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.near_me),
                label: Text(_isDetecting
                    ? 'Detecting Location...'
                    : 'Auto-Detect District'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const DistrictPickerScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Select District Manually',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
