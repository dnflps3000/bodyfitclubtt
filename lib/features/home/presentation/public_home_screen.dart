import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../messages/presentation/latest_public_message_card.dart';

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key, required this.onOpenSchedule});

  final VoidCallback onOpenSchedule;

  TextStyle? _homeCardTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        _buildNearestTrainingsCard(context),
        const SizedBox(height: AppSpacing.cardGap),
        _buildNewsCard(),
      ],
    );
  }

  Widget _buildNearestTrainingsCard(BuildContext context) {
    final now = DateTime.now();
    final scheduleEnd = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 14));

    final stream = FirebaseFirestore.instance
        .collection('trainingSessions')
        .where('isActive', isEqualTo: true)
        .where('status', isEqualTo: 'scheduled')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('startTime', isLessThan: Timestamp.fromDate(scheduleEnd))
        .orderBy('startTime')
        .limit(3)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(
                AppTexts.nearestTrainings,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: Text(AppTexts.trainingsLoadError),
              onTap: onOpenSchedule,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(
                AppTexts.nearestTrainings,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: Text(AppTexts.loading),
            ),
          );
        }

        final trainings =
            snapshot.data?.docs.map((document) {
              final data = document.data();

              return _PublicHomeTraining(
                trainingName:
                    data['trainingName'] as String? ?? AppTexts.unknownTraining,
                startTime:
                    (data['startTime'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
              );
            }).toList() ??
            [];

        if (trainings.isEmpty) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(
                AppTexts.nearestTrainings,
                style: _homeCardTitleStyle(context),
              ),
              subtitle: Text(AppTexts.noNearestTraining),
              onTap: onOpenSchedule,
            ),
          );
        }

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.cardInnerRadius),
            onTap: onOpenSchedule,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_month_outlined),
                  const SizedBox(width: AppSpacing.iconTextGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.nearestTrainings,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final training in trainings)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.listBottomGap,
                            ),
                            child: Text(
                              '${training.trainingName} - '
                              '${_formatPublicTrainingTime(training.startTime)}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsCard() {
    return const LatestPublicMessageCard();
  }

  String _formatPublicTrainingTime(DateTime dateTime) {
    final now = DateTime.now();

    if (_isSameDate(dateTime, now)) {
      return '${AppTexts.todayLower} ${_formatTime(dateTime)}';
    }

    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (_isSameDate(dateTime, tomorrow)) {
      return '${AppTexts.tomorrowLower} ${_formatTime(dateTime)}';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');

    return '$day.$month. ${_formatTime(dateTime)}';
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

class _PublicHomeTraining {
  const _PublicHomeTraining({
    required this.trainingName,
    required this.startTime,
  });

  final String trainingName;
  final DateTime startTime;
}
