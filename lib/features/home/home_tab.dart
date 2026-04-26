import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.card_membership),
            title: Text(AppTexts.membershipStatus),
            subtitle: Text('${AppTexts.remainingEntries}: 0'),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.event_available),
            title: Text(AppTexts.upcomingTraining),
            subtitle: Text('Zatiaľ nemáte rezervované žiadne cvičenie.'),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.campaign_outlined),
            title: Text(AppTexts.news),
            subtitle: Text('Tu sa budú zobrazovať novinky a správy od trénerov.'),
          ),
        ),
      ],
    );
  }
}