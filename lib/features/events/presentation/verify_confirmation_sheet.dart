import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/events_provider.dart';
import '../domain/event_model.dart';

class VerifyConfirmationSheet extends ConsumerStatefulWidget {
  final EventModel event;

  const VerifyConfirmationSheet({super.key, required this.event});

  @override
  ConsumerState<VerifyConfirmationSheet> createState() =>
      _VerifyConfirmationSheetState();
}

class _VerifyConfirmationSheetState
    extends ConsumerState<VerifyConfirmationSheet> {
  bool _isConfirming = false;

  Future<void> _handleConfirm() async {
    setState(() => _isConfirming = true);
    try {
      final repo = ref.read(eventsRepositoryProvider);
      final res = await repo.confirmEvent(widget.event.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Verification recorded!'),
            backgroundColor: AppColors.tertiaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm event.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.event.confirmationsCount;
    final progress = (count / 3).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: AppColors.secondary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Verify Event Legitimacy',
                    style: AppTypography.headlineLarge.copyWith(fontSize: 20)),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '3 distinct local user verifications are required for an event to become publicly verified.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 20),

          // 3-Gate Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceContainerHigh,
            color: progress >= 1.0
                ? AppColors.tertiaryContainer
                : AppColors.secondary,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$count of 3 Confirmations',
                  style: AppTypography.labelMedium),
              Text(progress >= 1.0 ? 'VERIFIED' : 'PENDING',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.primary)),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'By tapping "Verify", you confirm that this event is real, accurately described, and taking place at the specified venue.',
            style:
                AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isConfirming ? null : _handleConfirm,
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: _isConfirming
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Confirm & Verify Event'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
