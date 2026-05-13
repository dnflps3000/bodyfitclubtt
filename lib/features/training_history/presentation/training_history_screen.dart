import 'package:flutter/material.dart';
import '../../../core/theme/app_texts.dart';
import '../data/training_history_service.dart';
import 'training_history_detail_screen.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  final TrainingHistoryService _service = TrainingHistoryService();

  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    _from = todayStart.subtract(const Duration(days: 30));
    _to = todayStart.add(const Duration(days: 1));
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> _pickFromDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _from = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    });
  }

  Future<void> _pickToDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _to.subtract(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _to = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      ).add(const Duration(days: 1));
    });
  }

  void _setLast30Days() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    setState(() {
      _from = todayStart.subtract(const Duration(days: 30));
      _to = todayStart.add(const Duration(days: 1));
    });
  }

  void _setLast7Days() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    setState(() {
      _from = todayStart.subtract(const Duration(days: 7));
      _to = todayStart.add(const Duration(days: 1));
    });
  }

  Future<void> _openDetail(TrainingHistorySession session) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrainingHistoryDetailScreen(session: session),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _setLast7Days,
              child: const Text(AppTexts.last7Days),
            ),
            OutlinedButton(
              onPressed: _setLast30Days,
              child: const Text(AppTexts.last30Days),
            ),
            OutlinedButton.icon(
              onPressed: _pickFromDate,
              icon: const Icon(Icons.date_range),
              label: Text(
                '${AppTexts.fromDatePrefix}: ${_formatDateTime(_from).split(' ').first}',
              ),
            ),
            OutlinedButton.icon(
              onPressed: _pickToDate,
              icon: const Icon(Icons.event),
              label: Text(
                '${AppTexts.toDatePrefix}: ${_formatDateTime(_to.subtract(const Duration(days: 1))).split(' ').first}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(TrainingHistorySession session) {
    final statusText = session.isCancelled
        ? AppTexts.cancelled
        : session.isFinished
        ? AppTexts.finished
        : AppTexts.planned;

    return Card(
      child: ListTile(
        leading: Icon(
          session.isCancelled
              ? Icons.cancel_outlined
              : session.isFinished
              ? Icons.history
              : Icons.event_available,
        ),
        title: Text(session.trainingName),
        subtitle: Text(
          '${_formatDateTime(session.startTime)} – ${_formatTime(session.endTime)}\n'
          '${AppTexts.trainer}: ${session.trainerName}\n'
          '${AppTexts.capacityLabel}: ${session.reservedCount}/${session.capacity} • $statusText',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openDetail(session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.trainingHistory)),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(12), child: _buildFilters()),
          Expanded(
            child: StreamBuilder<List<TrainingHistorySession>>(
              stream: _service.watchTrainingHistory(from: _from, to: _to),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(AppTexts.trainingHistoryLoadError),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sessions = snapshot.data ?? [];

                if (sessions.isEmpty) {
                  return const Center(
                    child: Text(AppTexts.noTrainingHistoryInSelectedPeriod),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    return _buildSessionCard(sessions[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
