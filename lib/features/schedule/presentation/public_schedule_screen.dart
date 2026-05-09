import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../data/schedule_service.dart';
import '../domain/schedule_item.dart';

class PublicScheduleScreen extends StatefulWidget {
  const PublicScheduleScreen({super.key});

  @override
  State<PublicScheduleScreen> createState() => _PublicScheduleScreenState();
}

class _PublicScheduleScreenState extends State<PublicScheduleScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.schedule)),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: StreamBuilder<List<ScheduleItem>>(
              stream: ScheduleService().watchScheduleItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text(AppTexts.trainingsLoadError));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items =
                    (snapshot.data ?? []).where((item) {
                      return _isSameDate(item.session.startTime, _selectedDate);
                    }).toList()..sort((a, b) {
                      return a.session.startTime.compareTo(b.session.startTime);
                    });

                if (items.isEmpty) {
                  return const Center(
                    child: Text(AppTexts.noTrainingsForSelectedDay),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildScheduleCard(items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _nextSevenDays();

    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDate(day, _selectedDate);

          return ChoiceChip(
            selected: isSelected,
            label: Text(_formatDayLabel(day)),
            onSelected: (_) {
              setState(() {
                _selectedDate = day;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item) {
    return Card(
      child: ListTile(
        title: Text(item.trainingType.name),
        subtitle: Text(
          '${_formatTimeRange(item.session.startTime, item.session.endTime)}\n'
          '${AppTexts.trainer}: ${item.trainerName}\n'
          '${AppTexts.freeSpots}: ${item.session.freeSpots}/${item.session.capacity}',
        ),
        isThreeLine: true,
      ),
    );
  }

  List<DateTime> _nextSevenDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(7, (index) {
      return today.add(Duration(days: index));
    });
  }

  String _formatDayLabel(DateTime dateTime) {
    final now = DateTime.now();

    if (_isSameDate(dateTime, now)) {
      return AppTexts.today;
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (_isSameDate(dateTime, tomorrow)) {
      return AppTexts.tomorrow;
    }

    final weekdayIndex = dateTime.weekday - 1;
    final weekday = AppTexts.shortWeekdays[weekdayIndex];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$weekday $day.$month.';
  }

  String _formatTimeRange(DateTime startTime, DateTime endTime) {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
