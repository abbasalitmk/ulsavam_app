import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/presentation/pending_verification_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please log in.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Profile', style: AppTypography.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: user.avatar != null && user.avatar!.isNotEmpty ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null || user.avatar!.isEmpty
                  ? Text(user.displayName[0], style: AppTypography.displayLarge.copyWith(color: Colors.white, fontSize: 36))
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user.displayName, style: AppTypography.headlineLarge),
            const SizedBox(height: 4),
            Text(user.email ?? user.phoneNumber ?? '', style: AppTypography.bodySmall),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privacy Shield Status', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                        Text(
                          user.isInfoRevealed ? 'Name & photo visible to others' : 'Name & photo hidden in attendee lists',
                          style: AppTypography.bodySmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: user.isInfoRevealed,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(authProvider.notifier).updateProfile({'is_info_revealed': val});
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.hourglass_top, color: AppColors.primary),
              title: Text('My Pending Event Submissions', style: AppTypography.titleMedium.copyWith(fontSize: 16)),
              subtitle: const Text('Track 3-verification progress for events you submitted'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PendingVerificationScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: Text('Edit Profile & Settings', style: AppTypography.titleMedium.copyWith(fontSize: 16)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text('Log Out', style: AppTypography.titleMedium.copyWith(fontSize: 16, color: AppColors.error)),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
