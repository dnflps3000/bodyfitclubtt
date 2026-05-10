import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_texts.dart';

class ReservationQrScreen extends StatefulWidget {
  const ReservationQrScreen({
    super.key,
    required this.reservationId,
    required this.trainingSessionId,
    required this.trainingName,
    required this.startTime,
    required this.endTime,
  });

  final String reservationId;
  final String trainingSessionId;
  final String trainingName;
  final DateTime startTime;
  final DateTime endTime;

  @override
  State<ReservationQrScreen> createState() => _ReservationQrScreenState();
}

class _ReservationQrScreenState extends State<ReservationQrScreen> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  bool _handledScan = false;

  @override
  void initState() {
    super.initState();

    _subscription = FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservationId)
        .snapshots()
        .listen((snapshot) {
          final data = snapshot.data();

          if (data == null || _handledScan) {
            return;
          }

          final status = data['status'] as String? ?? '';
          final entryStatus = data['entryStatus'] as String? ?? '';

          if (status == 'attended' && entryStatus == 'used') {
            _handledScan = true;

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppTexts.qrCodeScanned)),
            );

            Navigator.of(context).pop();
          }
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _formatDateTimeRange() {
    final day = widget.startTime.day.toString().padLeft(2, '0');
    final month = widget.startTime.month.toString().padLeft(2, '0');
    final year = widget.startTime.year.toString();
    final startHour = widget.startTime.hour.toString().padLeft(2, '0');
    final startMinute = widget.startTime.minute.toString().padLeft(2, '0');
    final endHour = widget.endTime.hour.toString().padLeft(2, '0');
    final endMinute = widget.endTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $startHour:$startMinute - $endHour:$endMinute';
  }

  @override
  Widget build(BuildContext context) {
    final qrData = jsonEncode({
      'type': 'bodyfitclubtt_attendance',
      'reservationId': widget.reservationId,
      'trainingSessionId': widget.trainingSessionId,
    });

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.reservationQrCode)),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.trainingName,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(_formatDateTimeRange(), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppTexts.showQrToTrainer,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
