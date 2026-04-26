import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';
import 'schedule_item.dart';
import 'schedule_service.dart';
/* Zobrazuje obrazovku Rozvrh, teda zoznam tréningov, ich čas, 
   trénera, voľné miesta, popis a tlačidlo rezervácie.*/
class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final scheduleService = ScheduleService();

    return StreamBuilder<List<ScheduleItem>>(
      stream: scheduleService.watchScheduleItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(AppTexts.trainingsLoadError),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text(AppTexts.noTrainings),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final session = item.session;
            final trainingType = item.trainingType;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainingType.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatDateTime(session.startTime)} - ${_formatTime(session.endTime)}',
                    ),
                    const SizedBox(height: 8),
                    Text('${AppTexts.trainer}: ${item.trainerName}'),
                    const SizedBox(height: 8),
                    Text(
                      '${AppTexts.freeSpots}: ${session.freeSpots}/${session.capacity}',
                    ),
                    if (trainingType.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(trainingType.description),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: session.hasFreeSpots ? () {} : null,
                        child: Text(
                          session.hasFreeSpots
                              ? AppTexts.reserve
                              : AppTexts.fullCapacity,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}