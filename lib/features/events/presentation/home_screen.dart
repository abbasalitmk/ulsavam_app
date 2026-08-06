import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../districts/providers/districts_provider.dart';
import '../../districts/presentation/district_picker_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../providers/events_provider.dart';
import '../domain/event_model.dart';
import 'event_detail_screen.dart';
import 'explore_screen.dart';
import 'map_view_screen.dart';
import 'search_screen.dart';
import 'add_event_screen.dart';
import '../../calendar/presentation/festival_calendar_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBottomNav = 0;

  @override
  Widget build(BuildContext context) {
    final selectedDistrictName = ref.watch(selectedDistrictNameProvider);
    final selectedDistrictSlug = ref.watch(selectedDistrictSlugProvider);
    final happeningNowAsync = ref.watch(happeningNowEventsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.festival, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Text('Ulsavam', style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontSize: 22)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              if (authState.isAuthenticated) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top District Header & Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY IN KERALA',
                    style: AppTypography.labelMedium.copyWith(letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DistrictPickerScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          selectedDistrictName,
                          style: AppTypography.headlineLarge,
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 28),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            'Search events, festivals, venues...',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Happening Now Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Happening Now', style: AppTypography.titleMedium),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MapViewScreen()),
                      );
                    },
                    icon: const Icon(Icons.map, size: 16, color: AppColors.primary),
                    label: Text('View Map', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 230,
              child: happeningNowAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return Center(
                      child: Text(
                        'No live events currently happening in $selectedDistrictName.',
                        style: AppTypography.bodySmall,
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _buildEventCard(context, event);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Category Shortcuts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Explore Categories', style: AppTypography.titleMedium),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('Temple Poorams', Icons.temple_hindu, 'temple'),
                  _buildCategoryChip('Church Feasts', Icons.church, 'church'),
                  _buildCategoryChip('DJ & Music Shows', Icons.music_note, 'dj_music'),
                  _buildCategoryChip('Beach Meetups', Icons.beach_access, 'beach_meetup'),
                  _buildCategoryChip('Arts & Culture', Icons.palette, 'arts_culture'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Major Kerala Festival Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FestivalCalendarScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.onTertiaryContainer, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kerala Festival Calendar 2026',
                              style: AppTypography.titleMedium.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Thrissur Pooram, Onam, Vishu & district temple dates.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.onTertiaryContainer),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!authState.isAuthenticated) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddEventScreen()),
            );
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomNav,
        onTap: (index) {
          setState(() => _currentBottomNav = index);
          if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExploreScreen()));
          } else if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MapViewScreen()));
          } else if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FestivalCalendarScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title, IconData icon, String categorySlug) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: AppColors.primary),
        label: Text(title, style: AppTypography.labelMedium),
        backgroundColor: AppColors.surfaceContainer,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ExploreScreen(initialCategory: categorySlug)),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
        );
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.primaryContainer,
                image: event.coverImage != null && event.coverImage!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(event.coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${event.goingCount} Going',
                          style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.onSecondaryContainer),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${event.confirmationsCount} Verified',
                          style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.tertiaryContainer),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
