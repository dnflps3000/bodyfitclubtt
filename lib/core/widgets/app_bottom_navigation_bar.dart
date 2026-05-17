import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import '../theme/app_texts.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isManager,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isManager;

  static const double _defaultLabelSize = AppFonts.navigationLabel;
  static const double _minLabelSize = 8.5;

  double _calculateLabelSize(BuildContext context, List<String> labels) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final itemWidth = screenWidth / labels.length;

    // Menšia rezerva, aby sa text nezalamoval tesne pri okraji položky.
    final availableLabelWidth = itemWidth - 8;

    double labelSize = _defaultLabelSize;

    for (final label in labels) {
      while (labelSize > _minLabelSize) {
        final painter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontFamily: AppFonts.defaultFont,
              fontSize: _defaultLabelSize,
              fontWeight: FontWeight.w700,
            ).copyWith(fontSize: labelSize),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();

        if (painter.width <= availableLabelWidth) {
          break;
        }

        labelSize -= 0.5;
      }
    }

    return labelSize;
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppTexts.home,
      AppTexts.schedule,
      isManager ? AppTexts.management : AppTexts.reservations,
      if (!isManager) AppTexts.memberships,
      AppTexts.profile,
    ];

    final labelSize = _calculateLabelSize(context, labels);
    final theme = Theme.of(context);
    final navigationBarTheme = theme.navigationBarTheme;

    return NavigationBarTheme(
      data: navigationBarTheme.copyWith(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            fontFamily: AppFonts.defaultFont,
            fontSize: labelSize,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
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
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note),
            label: isManager ? AppTexts.management : AppTexts.reservations,
          ),
          if (!isManager)
            NavigationDestination(
              icon: Icon(Icons.card_membership_outlined),
              selectedIcon: Icon(Icons.card_membership),
              label: AppTexts.memberships,
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
