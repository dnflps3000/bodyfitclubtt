import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';
import '../home/presentation/home_tab.dart';
import '../profile/presentation/profile_tab.dart';
import '../reservations/presentation/reservations_tab.dart';
import '../schedule/presentation/schedule_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.user});

  final User user;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _scheduleTabVersion = 0;

  List<Widget> _buildTabs() {
    return [
      HomeTab(
        onOpenSchedule: () {
          setState(() {
            _scheduleTabVersion++;
            _selectedIndex = 1;
          });
        },
      ),
      ScheduleTab(key: ValueKey('schedule-tab-$_scheduleTabVersion')),
      const ReservationsTab(),
      ProfileTab(user: widget.user),
    ];
  }

  static const List<String> _titles = [
    AppTexts.home,
    AppTexts.schedule,
    AppTexts.reservations,
    AppTexts.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _buildTabs()[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppTexts.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: AppTexts.schedule,
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: AppTexts.reservations,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppTexts.profile,
          ),
        ],
      ),
    );
  }
}
