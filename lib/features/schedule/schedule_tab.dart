import 'package:flutter/material.dart';
import '../../core/theme/app_texts.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(AppTexts.schedulePlaceholder),
    );
  }
}