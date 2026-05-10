import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_roles.dart';
import '../../core/theme/app_texts.dart';
import '../home/presentation/home_tab.dart';
import '../profile/presentation/profile_tab.dart';
import '../reservations/presentation/reservations_tab.dart';
import '../schedule/presentation/schedule_tab.dart';
import '../schedule/presentation/schedule_management_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.user});

  final User user;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _scheduleTabVersion = 0;

  List<Widget> _buildTabs(String? role) {
    final isManager = role == AppRoles.admin || role == AppRoles.trainer;

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
      isManager
          ? ScheduleManagementScreen(role: role, showAppBar: false)
          : const ReservationsTab(),
      ProfileTab(user: widget.user),
    ];
  }

  List<String> _buildTitles(String? role) {
    final isManager = role == AppRoles.admin || role == AppRoles.trainer;

    return [
      AppTexts.home,
      AppTexts.schedule,
      isManager ? AppTexts.management : AppTexts.reservations,
      AppTexts.profile,
    ];
  }

  Stream<String?> _watchCurrentUserRole() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return data?['role'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _watchCurrentUserRole(),
      builder: (context, roleSnapshot) {
        final role = roleSnapshot.data;
        final isManager = role == AppRoles.admin || role == AppRoles.trainer;
        final titles = _buildTitles(role);
        final tabs = _buildTabs(role);

        return Scaffold(
          appBar: AppBar(title: Text(titles[_selectedIndex])),
          body: tabs[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: AppTexts.home,
              ),
              const NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: AppTexts.schedule,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_note_outlined),
                selectedIcon: const Icon(Icons.event_note),
                label: isManager ? AppTexts.management : AppTexts.reservations,
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: AppTexts.profile,
              ),
            ],
          ),
        );
      },
    );
  }
}
