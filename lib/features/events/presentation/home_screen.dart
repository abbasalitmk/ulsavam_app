import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/skeletons.dart';
import '../../../core/widgets/event_cards.dart';
import '../../districts/providers/districts_provider.dart';
import '../../districts/presentation/district_picker_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../providers/events_provider.dart';
import '../domain/event_model.dart';
import 'event_detail_screen.dart';
import 'explore_screen.dart';
import 'search_screen.dart';
import 'add_event_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../profile/presentation/profile_screen.dart';

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

bool _isWithinNextWeek(String eventDateStr) {
  final eventDate = DateTime.tryParse(eventDateStr);
  if (eventDate == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekFromNow = today.add(const Duration(days: 7));
  final day = DateTime(eventDate.year, eventDate.month, eventDate.day);
  return !day.isBefore(today) && !day.isAfter(weekFromNow);
}

class HomeScreen extends ConsumerStatefulWidget {
  /// Switches the hosting [MainShell]'s tab instead of pushing a new route.
  /// Left null when this screen is used standalone (e.g. in tests), in
  /// which case actions fall back to pushing the destination screen.
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final selectedDistrictName = ref.watch(selectedDistrictNameProvider);
    final districtSlug = ref.watch(selectedDistrictSlugProvider);
    final happeningNowAsync = ref.watch(happeningNowEventsProvider);
    final districtFilter = EventsFilter(district: districtSlug);
    final districtEventsAsync =
        ref.watch(exploreEventsProvider(districtFilter));
    final authState = ref.watch(authProvider);

    final thisWeekEvents = (districtEventsAsync.valueOrNull ?? [])
        .where((e) => _isWithinNextWeek(e.eventDate))
        .toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.festival, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 10),
            Text('Ulsavam',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.primary, fontSize: 21)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              if (authState.isAuthenticated) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
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
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: authState.user?.displayImageUrl != null &&
                        authState.user!.displayImageUrl!.isNotEmpty
                    ? NetworkImage(authState.user!.displayImageUrl!)
                    : null,
                child: authState.user?.displayImageUrl == null ||
                        authState.user!.displayImageUrl!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.refresh(happeningNowEventsProvider.future),
          ref.refresh(exploreEventsProvider(districtFilter).future),
        ]),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header: greeting + district selector + search
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryContainer.withOpacity(0.10),
                      AppColors.surface,
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()} 👋',
                      style: AppTypography.bodySmall.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'EXPLORE KERALA IN',
                      style: AppTypography.labelMedium.copyWith(
                          letterSpacing: 1.2, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const DistrictPickerScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              selectedDistrictName,
                              style: AppTypography.headlineLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 28, color: AppColors.onSurface),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        );
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: AppColors.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: AppColors.onSurfaceVariant),
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

              const SizedBox(height: 24),

              // Quick Category Shortcuts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(
                  icon: Icons.category_outlined,
                  iconColor: AppColors.secondary,
                  title: 'Explore Categories',
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildCategoryChip('Temple\nPoorams', Icons.temple_hindu,
                        'temple', AppColors.primary),
                    _buildCategoryChip('Church\nFeasts', Icons.church, 'church',
                        AppColors.secondary),
                    _buildCategoryChip('DJ &\nMusic', Icons.music_note,
                        'dj_music', AppColors.tertiary),
                    _buildCategoryChip('Beach\nMeetups', Icons.beach_access,
                        'beach_meetup', AppColors.primary),
                    _buildCategoryChip('Arts &\nCulture', Icons.palette,
                        'arts_culture', AppColors.secondary),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Happening Today Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.error,
                  title: 'Happening Today',
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: happeningNowAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return _EmptySectionHint(
                        icon: Icons.event_available_outlined,
                        message:
                            'Nothing live right now in $selectedDistrictName.',
                        subMessage: 'Check what\'s coming up this week below ↓',
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _TodayEventCard(event: event);
                      },
                    );
                  },
                  loading: () => const EventCardSkeletonRow(),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ),

              const SizedBox(height: 28),

              // This Week Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SectionHeader(
                  icon: Icons.date_range_rounded,
                  iconColor: AppColors.tertiary,
                  title: 'This Week in Kerala',
                  trailing: thisWeekEvents.isEmpty
                      ? null
                      : TextButton(
                          onPressed: () {
                            if (widget.onNavigateToTab != null) {
                              widget.onNavigateToTab!(1);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ExploreScreen()),
                              );
                            }
                          },
                          child: Text('View All',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.primary)),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              districtEventsAsync.when(
                data: (_) {
                  if (thisWeekEvents.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _EmptySectionHint(
                        icon: Icons.beach_access_outlined,
                        message: 'No events lined up in the next 7 days.',
                        subMessage:
                            'Check back soon or explore other districts.',
                        compact: true,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (final event in thisWeekEvents.take(5))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EventDateCard(event: event),
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: EventListSkeleton(count: 3, padding: EdgeInsets.zero),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Error: $err', style: AppTypography.bodySmall),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
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
        label: const Text('Add Event',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCategoryChip(
      String title, IconData icon, String categorySlug, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => ExploreScreen(initialCategory: categorySlug)),
          );
        },
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTypography.labelMedium
                    .copyWith(fontSize: 11, letterSpacing: 0, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(title,
                style: AppTypography.titleMedium.copyWith(fontSize: 18)),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptySectionHint extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final bool compact;

  const _EmptySectionHint({
    required this.icon,
    required this.message,
    this.subMessage,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
        ),
        const SizedBox(height: 12),
        Text(message,
            style: AppTypography.bodySmall, textAlign: TextAlign.center),
        if (subMessage != null) ...[
          const SizedBox(height: 2),
          Text(
            subMessage!,
            style: AppTypography.bodySmall
                .copyWith(fontSize: 12, color: AppColors.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (compact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: content,
      ),
    );
  }
}

class _TodayEventCard extends StatelessWidget {
  final EventModel event;

  const _TodayEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id)),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 130,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.primaryContainer,
                      child: event.coverImage != null &&
                              event.coverImage!.isNotEmpty
                          ? Image.network(event.coverImage!, fit: BoxFit.cover)
                          : Icon(Icons.festival,
                              color: Colors.white.withOpacity(0.8), size: 40),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.45)
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                    style: AppTypography.titleMedium.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: EventBadge(
                            text: '${event.goingCount} Going',
                            color: AppColors.secondaryContainer,
                            textColor: AppColors.onSecondaryContainer),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: EventBadge(
                          text: '${event.confirmationsCount} Verified',
                          color: AppColors.tertiaryContainer.withOpacity(0.15),
                          textColor: AppColors.tertiaryContainer,
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
