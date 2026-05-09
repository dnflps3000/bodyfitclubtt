import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_texts.dart';
import '../data/reservation_service.dart';

class AttendanceQrScannerScreen extends StatefulWidget {
  const AttendanceQrScannerScreen({super.key, this.trainerId});

  final String? trainerId;

  @override
  State<AttendanceQrScannerScreen> createState() =>
      _AttendanceQrScannerScreenState();
}

class _AttendanceQrScannerScreenState extends State<AttendanceQrScannerScreen> {
  final ReservationService _reservationService = ReservationService();

  bool _isProcessing = false;

  Future<void> _handleQrCode(String rawValue) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final decoded = jsonDecode(rawValue);

      if (decoded is! Map<String, dynamic> ||
          decoded['type'] != 'bodyfitclubtt_attendance') {
        throw Exception('invalid-qr-code');
      }

      final reservationId = decoded['reservationId'] as String? ?? '';
      final trainingSessionId = decoded['trainingSessionId'] as String? ?? '';

      if (reservationId.isEmpty || trainingSessionId.isEmpty) {
        throw Exception('invalid-qr-code');
      }

      await _reservationService.markReservationAttendance(
        reservationId: reservationId,
        trainingSessionId: trainingSessionId,
        attended: true,
        trainerId: widget.trainerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.qrScanSuccessful)));

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.invalidQrCode)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.scanQrCodes)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: MobileScanner(
                            onDetect: (capture) {
                              final barcodes = capture.barcodes;

                              if (barcodes.isEmpty) {
                                return;
                              }

                              final rawValue = barcodes.first.rawValue;

                              if (rawValue == null || rawValue.isEmpty) {
                                return;
                              }

                              _handleQrCode(rawValue);
                            },
                          ),
                        ),
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                          ),
                        ),
                        if (_isProcessing)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                AppTexts.scanQrCodeHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
