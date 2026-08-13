import 'package:flutter/material.dart';
import 'shimmer.dart';

/// Skeleton for the horizontal "happening now" event card on the home screen.
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(
              height: 120,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 16, width: 160),
                  SizedBox(height: 8),
                  ShimmerBox(height: 12, width: 120),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ShimmerBox(
                          height: 18,
                          width: 60,
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      SizedBox(width: 6),
                      ShimmerBox(
                          height: 18,
                          width: 70,
                          borderRadius: BorderRadius.all(Radius.circular(4))),
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

/// Horizontal row of [EventCardSkeleton]s, matching the home screen's
/// "Happening Now" carousel while data is loading.
class EventCardSkeletonRow extends StatelessWidget {
  final int count;

  const EventCardSkeletonRow({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      itemBuilder: (context, index) => const EventCardSkeleton(),
    );
  }
}

/// Skeleton for a single row in a list-style event listing
/// (explore, pending verification, calendar list view).
class EventListItemSkeleton extends StatelessWidget {
  const EventListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(
                  width: 90,
                  height: 90,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(height: 16, width: double.infinity),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 140),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ShimmerBox(
                            height: 18,
                            width: 56,
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        SizedBox(width: 8),
                        ShimmerBox(height: 12, width: 100),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A vertical list of [EventListItemSkeleton]s.
class EventListSkeleton extends StatelessWidget {
  final int count;
  final EdgeInsetsGeometry padding;

  const EventListSkeleton({
    super.key,
    this.count = 5,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => const EventListItemSkeleton(),
    );
  }
}

/// Skeleton for a plain [ListTile]-style row (notifications, attendees).
class TileSkeleton extends StatelessWidget {
  const TileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const ShimmerBox(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(height: 14, width: double.infinity),
                  SizedBox(height: 8),
                  ShimmerBox(height: 12, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A vertical list of [TileSkeleton]s.
class TileListSkeleton extends StatelessWidget {
  final int count;

  const TileListSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: count,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => const TileSkeleton(),
    );
  }
}

/// Skeleton for a grid card, matching the festival calendar's grid view.
class EventGridItemSkeleton extends StatelessWidget {
  const EventGridItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(
                  height: 80,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              SizedBox(height: 8),
              ShimmerBox(height: 14, width: double.infinity),
              SizedBox(height: 6),
              ShimmerBox(height: 14, width: 80),
              Spacer(),
              ShimmerBox(height: 12, width: 60),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of [EventGridItemSkeleton]s, matching the calendar screen's grid layout.
class EventGridSkeleton extends StatelessWidget {
  final int count;

  const EventGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: count,
      itemBuilder: (context, index) => const EventGridItemSkeleton(),
    );
  }
}

/// Skeleton for the small horizontal cards in the map view's bottom carousel.
class MapCardSkeleton extends StatelessWidget {
  const MapCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const ShimmerBox(
                width: 70,
                height: 70,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  ShimmerBox(height: 14, width: double.infinity),
                  SizedBox(height: 6),
                  ShimmerBox(height: 12, width: 100),
                  SizedBox(height: 6),
                  ShimmerBox(height: 10, width: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal row of [MapCardSkeleton]s for the map view carousel.
class MapCardSkeletonRow extends StatelessWidget {
  final int count;

  const MapCardSkeletonRow({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: count,
      itemBuilder: (context, index) => const MapCardSkeleton(),
    );
  }
}

/// Full-page skeleton for the event detail screen, mirroring its layout:
/// a hero image, status row, action buttons, and body text blocks.
class EventDetailSkeleton extends StatelessWidget {
  const EventDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(height: 260, borderRadius: BorderRadius.zero),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(
                      height: 24,
                      width: 180,
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: ShimmerBox(
                              height: 48,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)))),
                      SizedBox(width: 12),
                      Expanded(
                          child: ShimmerBox(
                              height: 48,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)))),
                    ],
                  ),
                  SizedBox(height: 24),
                  ShimmerBox(height: 1, width: double.infinity),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ShimmerBox(
                          width: 40,
                          height: 40,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      SizedBox(width: 12),
                      ShimmerBox(height: 16, width: 160),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ShimmerBox(
                          width: 40,
                          height: 40,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      SizedBox(width: 12),
                      ShimmerBox(height: 16, width: 140),
                    ],
                  ),
                  SizedBox(height: 16),
                  ShimmerBox(height: 1, width: double.infinity),
                  SizedBox(height: 16),
                  ShimmerBox(height: 18, width: 140),
                  SizedBox(height: 10),
                  ShimmerBox(height: 12, width: double.infinity),
                  SizedBox(height: 6),
                  ShimmerBox(height: 12, width: double.infinity),
                  SizedBox(height: 6),
                  ShimmerBox(height: 12, width: 220),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
