import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../data/discount_service.dart';

class RequestDiscountScreen extends StatefulWidget {
  const RequestDiscountScreen({super.key});

  @override
  State<RequestDiscountScreen> createState() => _RequestDiscountScreenState();
}

class _RequestDiscountScreenState extends State<RequestDiscountScreen> {
  final DiscountService _discountService = DiscountService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _noteController = TextEditingController();

  String _selectedType = 'student';
  File? _documentFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _discountTypeLabel(String type) {
    switch (type) {
      case 'student':
        return AppTexts.discountTypeStudent;
      case 'senior':
        return AppTexts.discountTypeSenior;
      case 'ztp':
        return AppTexts.discountTypeZtp;
      case 'individual':
        return AppTexts.discountTypeIndividual;
      default:
        return type;
    }
  }

  Future<void> _pickDocument(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (pickedFile == null) return;

    setState(() {
      _documentFile = File(pickedFile.path);
    });
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final documentFile = _documentFile;

    if (documentFile == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.discountDocumentRequired)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _discountService.requestDiscount(
        requestedType: _selectedType,
        documentFile: documentFile,
        note: _noteController.text,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.discountRequestSent)),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      final message =
          error.toString().contains('discount-request-already-pending')
          ? AppTexts.discountRequestAlreadyPending
          : AppTexts.discountRequestError;

      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const discountTypes = ['student', 'senior', 'ztp', 'individual'];

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.requestDiscount)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(
            AppTexts.discountRequestDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(labelText: AppTexts.discountType),
            items: [
              for (final type in discountTypes)
                DropdownMenuItem(
                  value: type,
                  child: Text(_discountTypeLabel(type)),
                ),
            ],
            onChanged: _isSaving
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedType = value;
                    });
                  },
          ),
          const SizedBox(height: AppSpacing.cardGap),
          TextField(
            controller: _noteController,
            enabled: !_isSaving,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: AppTexts.discountRequestNote,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.discountDocument,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppTexts.discountDocumentDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _pickDocument(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text(AppTexts.takeDiscountDocumentPhoto),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _pickDocument(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text(
                          AppTexts.chooseDiscountDocumentFromGallery,
                        ),
                      ),
                    ],
                  ),
                  if (_documentFile != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppTexts.discountDocumentSelected,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppTexts.sendRequest),
          ),
        ],
      ),
    );
  }
}
