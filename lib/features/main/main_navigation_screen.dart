import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_roles.dart';
import '../../core/theme/app_texts.dart';
import '../../core/widgets/app_bottom_navigation_bar.dart';
import '../../core/widgets/app_menu_button.dart';
import '../home/presentation/home_tab.dart';
import '../profile/presentation/profile_tab.dart';
import '../reservations/presentation/reservations_tab.dart';
import '../schedule/presentation/schedule_tab.dart';
import '../schedule/presentation/schedule_management_screen.dart';
import '../settings/data/settings_service.dart';
import '../memberships/presentation/my_memberships_screen.dart';

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

    if (isManager) {
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
        ScheduleManagementScreen(role: role, showAppBar: false),
        ProfileTab(user: widget.user),
      ];
    }

    return [
      HomeTab(
        onOpenSchedule: () {
          setState(() {
            _scheduleTabVersion++;
            _selectedIndex = 1;
          });
        },
        onOpenReservations: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        onOpenMemberships: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
      ),
      ScheduleTab(key: ValueKey('schedule-tab-$_scheduleTabVersion')),
      const ReservationsTab(),
      const MyMembershipsScreen(),
      ProfileTab(user: widget.user),
    ];
  }

  List<String> _buildTitles(String? role) {
    final isManager = role == AppRoles.admin || role == AppRoles.trainer;

    if (isManager) {
      return [
        AppTexts.home,
        AppTexts.schedule,
        AppTexts.management,
        AppTexts.profile,
      ];
    }

    return [
      AppTexts.home,
      AppTexts.schedule,
      AppTexts.reservations,
      AppTexts.memberships,
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
    final settingsService = SettingsService.instance;

    return AnimatedBuilder(
      animation: settingsService,
      builder: (context, _) {
        return StreamBuilder<String?>(
          stream: _watchCurrentUserRole(),
          builder: (context, roleSnapshot) {
            final role = roleSnapshot.data;
            final isManager =
                role == AppRoles.admin || role == AppRoles.trainer;
            final titles = _buildTitles(role);
            final tabs = _buildTabs(role);
            final safeSelectedIndex = _selectedIndex >= tabs.length
                ? 0
                : _selectedIndex;

            if (safeSelectedIndex != _selectedIndex) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                setState(() {
                  _selectedIndex = safeSelectedIndex;
                });
              });
            }
            final menuButton = AppMenuButton(
              showLogin: false,
              showLogout: true,
              onLogout: () async {
                await FirebaseAuth.instance.signOut();
              },
            );
            return Scaffold(
              appBar: AppBar(
                title: Text(titles[safeSelectedIndex]),
                leading: settingsService.isRightHanded ? null : menuButton,
                actions: settingsService.isRightHanded ? [menuButton] : null,
              ),
              body: tabs[safeSelectedIndex],
              bottomNavigationBar: AppBottomNavigationBar(
                selectedIndex: safeSelectedIndex,
                isManager: isManager,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
