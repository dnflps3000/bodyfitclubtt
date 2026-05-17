import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../../core/widgets/day_card_selector.dart';
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
      appBar: AppBar(title: Text(AppTexts.schedule)),
      body: StreamBuilder<List<ScheduleItem>>(
        stream: ScheduleService().watchScheduleItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(AppTexts.trainingsLoadError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allItems = snapshot.data ?? [];

          final items =
              allItems.where((item) {
                return _isSameDate(item.session.startTime, _selectedDate);
              }).toList()..sort((a, b) {
                return a.session.startTime.compareTo(b.session.startTime);
              });

          return Column(
            children: [
              _buildDaySelector(),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            AppTexts.noTrainingsForSelectedDay,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.cardGap),
                        itemBuilder: (context, index) {
                          return _buildScheduleCard(items[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _nextSevenDays();

    return DayCardSelector(
      key: const PageStorageKey('public-schedule-day-selector'),
      days: days,
      selectedDate: _selectedDate,
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget _buildScheduleCard(ScheduleItem item) {
    final description = item.trainingType.description.trim();

    return Card(
      child: ListTile(
        title: Text(item.trainingType.name),
        subtitle: Text(
          '${_formatTimeRange(item.session.startTime, item.session.endTime)}\n'
          '${AppTexts.trainer}: ${item.trainerName}\n'
          '${AppTexts.freeSpots}: ${item.session.freeSpots}/${item.session.capacity}'
          '${description.isNotEmpty ? '\n$description' : ''}',
        ),
        isThreeLine: description.isEmpty,
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
