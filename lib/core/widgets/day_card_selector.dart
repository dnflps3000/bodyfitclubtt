import 'package:flutter/material.dart';
import '../theme/app_texts.dart';

class DayCardSelector extends StatefulWidget {
  const DayCardSelector({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<DayCardSelector> createState() => _DayCardSelectorState();
}

class _DayCardSelectorState extends State<DayCardSelector> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _cardKeys;

  @override
  void initState() {
    super.initState();
    _cardKeys = List.generate(widget.days.length, (_) => GlobalKey());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollSelectedDateToCenter();
    });
  }

  @override
  void didUpdateWidget(covariant DayCardSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.days.length != widget.days.length) {
      _cardKeys = List.generate(widget.days.length, (_) => GlobalKey());
    }

    if (!_isSameDate(oldWidget.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollSelectedDateToCenter();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollSelectedDateToCenter() {
    if (!_scrollController.hasClients) {
      return;
    }

    final selectedIndex = widget.days.indexWhere((day) {
      return _isSameDate(day, widget.selectedDate);
    });

    if (selectedIndex == -1) {
      return;
    }

    const cardWidth = 104.0;
    const separatorWidth = 10.0;
    const horizontalPadding = 16.0;

    final viewportWidth = _scrollController.position.viewportDimension;
    final itemCenter =
        horizontalPadding +
        selectedIndex * (cardWidth + separatorWidth) +
        cardWidth / 2;

    final targetOffset = itemCenter - viewportWidth / 2;

    final minOffset = _scrollController.position.minScrollExtent;
    final maxOffset = _scrollController.position.maxScrollExtent;

    final clampedOffset = targetOffset.clamp(minOffset, maxOffset).toDouble();

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        scrollDirection: Axis.horizontal,
        itemCount: widget.days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final day = widget.days[index];
          final isSelected = _isSameDate(day, widget.selectedDate);

          return _DayCard(
            key: _cardKeys[index],
            date: day,
            isSelected: isSelected,
            onTap: () {
              widget.onDateSelected(day);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollSelectedDateToCenter();
              });
            },
          );
        },
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 104,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.18)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.45)
                : colorScheme.outline.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDayName(date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(date),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDayName(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = target.difference(today).inDays;

  if (difference == 0) {
    return AppTexts.today;
  }

  if (difference == 1) {
    return AppTexts.tomorrow;
  }

  return AppTexts.shortWeekdays[date.weekday - 1];
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day.$month.';
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
