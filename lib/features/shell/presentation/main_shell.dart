import 'package:flutter/material.dart';
import '../../calendar/presentation/event_calendar_screen.dart';
import '../../events/presentation/explore_screen.dart';
import '../../events/presentation/home_screen.dart';
import '../../events/presentation/map_view_screen.dart';

/// Hosts the four primary sections (Home, Explore, Map, Calendar) behind a
/// single persistent bottom navigation bar. Switching tabs swaps an
/// [IndexedStack] entry instead of pushing a new route, so the nav bar never
/// disappears and each tab keeps its scroll/filter state while hidden.
class MainShell extends StatefulWidget {
  final int initialIndex;

  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  static const _tabs = [
    HomeScreen(),
    ExploreScreen(),
    MapViewScreen(),
    EventCalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendar'),
        ],
      ),
    );
  }
}
