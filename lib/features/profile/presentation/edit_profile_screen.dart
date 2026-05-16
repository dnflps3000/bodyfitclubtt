import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_texts.dart';
import '../../audit/data/audit_log_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.user,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialPublicName,
    this.initialPhotoUrl,
    this.providerPhotoUrl,
  });

  final User user;
  final String initialFirstName;
  final String initialLastName;
  final String initialPublicName;
  final String? initialPhotoUrl;
  final String? providerPhotoUrl;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final AuditLogService _auditLogService = AuditLogService();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _publicNameController;

  String? _photoUrl;
  bool _saving = false;
  bool _photoSaving = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _publicNameController = TextEditingController(
      text: widget.initialPublicName,
    );
    _photoUrl = widget.initialPhotoUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _publicNameController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _profileChanges({
    required String? newFirstName,
    required String? newLastName,
    required String? newPublicName,
    required String? newDisplayName,
  }) {
    final changes = <String, dynamic>{};

    void addChange(String key, Object? oldValue, Object? newValue) {
      if (newValue != null && oldValue != newValue) {
        changes[key] = {'oldValue': oldValue, 'newValue': newValue};
      }
    }

    addChange('firstName', widget.initialFirstName, newFirstName);
    addChange('lastName', widget.initialLastName, newLastName);
    addChange('publicName', widget.initialPublicName, newPublicName);
    addChange('displayName', widget.user.displayName, newDisplayName);

    return changes;
  }

  bool _isCurrentPhotoManuallyUpdated() {
    final currentPhotoUrl = _photoUrl;

    if (currentPhotoUrl == null || currentPhotoUrl.isEmpty) {
      return false;
    }

    final providerPhotoUrl = widget.providerPhotoUrl;

    if (providerPhotoUrl == null || providerPhotoUrl.isEmpty) {
      return true;
    }

    return currentPhotoUrl != providerPhotoUrl;
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final publicName = _publicNameController.text.trim();

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final effectiveFirstName = firstName.isNotEmpty
        ? firstName
        : widget.initialFirstName.trim();

    final effectiveLastName = lastName.isNotEmpty
        ? lastName
        : widget.initialLastName.trim();

    if (firstName.isNotEmpty) {
      updates['firstName'] = firstName;
    }

    if (lastName.isNotEmpty) {
      updates['lastName'] = lastName;
    }

    if (publicName.isNotEmpty) {
      updates['publicName'] = publicName;
    } else if (firstName.isNotEmpty &&
        widget.initialPublicName.trim().isEmpty) {
      updates['publicName'] = firstName;
    }

    String? newDisplayName;

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      final displayName = '$effectiveFirstName $effectiveLastName'.trim();

      if (displayName.isNotEmpty) {
        updates['displayName'] = displayName;
        newDisplayName = displayName;
      }
    }

    if (updates.length == 1) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (newDisplayName != null) {
        await widget.user.updateDisplayName(newDisplayName);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .set(updates, SetOptions(merge: true));

      final changes = _profileChanges(
        newFirstName: updates['firstName'] as String?,
        newLastName: updates['lastName'] as String?,
        newPublicName: updates['publicName'] as String?,
        newDisplayName: updates['displayName'] as String?,
      );

      if (changes.isNotEmpty) {
        await _auditLogService.createLogWithUsers(
          category: 'profile',
          action: 'profile_updated',
          targetType: 'user',
          targetId: widget.user.uid,
          targetUserId: widget.user.uid,
          actor: widget.user,
          title: AppTexts.auditProfileUpdatedTitle,
          description: AppTexts.auditProfileUpdatedDescription,
          changes: changes,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.profileSaved)));

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppTexts.profileSaveError)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _showPhotoOptions() async {
    if (_photoSaving || _saving) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text(AppTexts.chooseFromGallery),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickAndUploadPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text(AppTexts.takePhoto),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickAndUploadPhoto(ImageSource.camera);
                },
              ),
              if (_photoUrl != null && _photoUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: const Text(AppTexts.editPhoto),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _editCurrentPhoto();
                  },
                ),
              if (_photoUrl != null && _photoUrl!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text(AppTexts.removePhoto),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _removeProfilePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<CroppedFile?> _cropProfilePhoto(String sourcePath) async {
    final colorScheme = Theme.of(context).colorScheme;

    return ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppTexts.cropProfilePhoto,
          toolbarColor: colorScheme.surface,
          toolbarWidgetColor: colorScheme.onSurface,
          activeControlsWidgetColor: colorScheme.primary,
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: AppTexts.cropProfilePhoto,
          cropStyle: CropStyle.circle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
  }

  Future<void> _uploadCroppedProfilePhoto(CroppedFile croppedFile) async {
    setState(() {
      _photoSaving = true;
    });

    final file = File(croppedFile.path);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child(widget.user.uid)
        .child('profile.jpg');

    await storageRef.putFile(file, SettableMetadata(contentType: 'image/jpeg'));

    final downloadUrl = await storageRef.getDownloadURL();

    await widget.user.updatePhotoURL(downloadUrl);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .set({
          'photoURL': downloadUrl,
          'photoUpdatedManually': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

    await _auditLogService.createLogWithUsers(
      category: 'profile',
      action: 'profile_photo_updated',
      targetType: 'user',
      targetId: widget.user.uid,
      targetUserId: widget.user.uid,
      actor: widget.user,
      title: AppTexts.auditProfilePhotoUpdatedTitle,
      description: AppTexts.auditProfilePhotoUpdatedDescription,
      changes: {
        'photoURL': {'oldValue': _photoUrl, 'newValue': downloadUrl},
        'photoUpdatedManually': {
          'oldValue': _isCurrentPhotoManuallyUpdated(),
          'newValue': true,
        },
      },
    );

    if (!mounted) return;

    setState(() {
      _photoUrl = downloadUrl;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppTexts.profilePhotoUpdated)));
  }

  Future<File> _downloadCurrentProfilePhoto(String photoUrl) async {
    final uri = Uri.parse(photoUrl);
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('profile-photo-download-failed');
    }

    final bytes = await response.fold<List<int>>(
      <int>[],
      (previous, element) => previous..addAll(element),
    );

    final tempFile = File(
      '${Directory.systemTemp.path}/profile_photo_${widget.user.uid}.jpg',
    );

    return tempFile.writeAsBytes(bytes, flush: true);
  }

  Future<void> _editCurrentPhoto() async {
    final currentPhotoUrl = _photoUrl;

    if (currentPhotoUrl == null || currentPhotoUrl.isEmpty) {
      return;
    }

    try {
      final photoFile = await _downloadCurrentProfilePhoto(currentPhotoUrl);

      if (!mounted) return;

      final croppedFile = await _cropProfilePhoto(photoFile.path);

      if (croppedFile == null) {
        return;
      }

      await _uploadCroppedProfilePhoto(croppedFile);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.profilePhotoUpdateError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _photoSaving = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      final croppedFile = await _cropProfilePhoto(pickedFile.path);

      if (croppedFile == null) {
        return;
      }

      await _uploadCroppedProfilePhoto(croppedFile);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.profilePhotoUpdateError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _photoSaving = false;
        });
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    setState(() {
      _photoSaving = true;
    });

    try {
      final fallbackPhotoUrl = widget.providerPhotoUrl;

      await widget.user.updatePhotoURL(fallbackPhotoUrl);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .set({
            'photoURL': fallbackPhotoUrl,
            'photoUpdatedManually': false,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      await _auditLogService.createLogWithUsers(
        category: 'profile',
        action: 'profile_photo_removed',
        targetType: 'user',
        targetId: widget.user.uid,
        targetUserId: widget.user.uid,
        actor: widget.user,
        title: AppTexts.auditProfilePhotoRemovedTitle,
        description: AppTexts.auditProfilePhotoRemovedDescription,
        changes: {
          'photoURL': {'oldValue': _photoUrl, 'newValue': fallbackPhotoUrl},
          'photoUpdatedManually': {
            'oldValue': _isCurrentPhotoManuallyUpdated(),
            'newValue': false,
          },
        },
      );

      if (!mounted) return;

      setState(() {
        _photoUrl = fallbackPhotoUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.profilePhotoUpdated)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.profilePhotoRemoveError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _photoSaving = false;
        });
      }
    }
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(56),
        onTap: _showPhotoOptions,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 52,
              child: ClipOval(
                child: _photoUrl != null && _photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _photoUrl!,
                        width: 104,
                        height: 104,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        memCacheWidth: 208,
                        memCacheHeight: 208,
                        placeholder: (context, url) {
                          return const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const Icon(Icons.person, size: 52);
                        },
                      )
                    : const Icon(Icons.person, size: 52),
              ),
            ),
            CircleAvatar(
              radius: 18,
              child: _photoSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt_outlined, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.editProfile)),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            _buildProfilePhoto(),
            const SizedBox(height: AppSpacing.cardGap),
            const Center(child: Text(AppTexts.changeProfilePhoto)),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: AppTexts.firstName,
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      TextFormField(
                        controller: _lastNameController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: AppTexts.lastName,
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onFieldSubmitted: (_) => _saveProfile(),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      TextFormField(
                        controller: _publicNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: AppTexts.publicName,
                          hintText: AppTexts.publicNameHint,
                          prefixIcon: Icon(Icons.alternate_email_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _saving ? null : _saveProfile,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text(AppTexts.save),
            ),
          ],
        ),
      ),
    );
  }
}
