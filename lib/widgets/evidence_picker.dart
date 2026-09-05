import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';

class EvidencePicker extends StatefulWidget {
  final List<String> initialEvidence;
  final ValueChanged<List<String>> onChanged;

  const EvidencePicker({
    super.key,
    this.initialEvidence = const [],
    required this.onChanged,
  });

  @override
  State<EvidencePicker> createState() => _EvidencePickerState();
}

class _EvidencePickerState extends State<EvidencePicker> {
  final ImagePicker _picker = ImagePicker();

  late List<String> _evidence;

  @override
  void initState() {
    super.initState();
    _evidence = List<String>.from(widget.initialEvidence);
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (files.isEmpty) return;

      setState(() {
        _evidence.addAll(
          files.map((file) => file.path),
        );
      });

      widget.onChanged(
        List<String>.from(_evidence),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to select images.',
      );
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _evidence.add(file.path);
      });

      widget.onChanged(
        List<String>.from(_evidence),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to open camera.',
      );
    }
  }

  void _removeEvidence(int index) {
    setState(() {
      _evidence.removeAt(index);
    });

    widget.onChanged(
      List<String>.from(_evidence),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Add Evidence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Select screenshots or photos related to your complaint.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                _OptionTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  subtitle: 'Select one or more images',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),

                const SizedBox(height: 12),

                _OptionTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take Photo',
                  subtitle: 'Capture evidence using camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromCamera();
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildEvidencePreview(
      String path,
      int index,
      ) {
    final file = File(path);

    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              file,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.insert_drive_file_outlined,
                    size: 32,
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _removeEvidence(index),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: 0.65,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showPickerOptions,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: 0.25,
                ),
              ),
              color: AppColors.primary.withValues(
                alpha: 0.04,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Add Evidence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Gallery or Camera',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Screenshots, payment proof, messages or other relevant images.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_evidence.isNotEmpty) ...[
          const SizedBox(height: 16),

          Text(
            '${_evidence.length} evidence item${_evidence.length == 1 ? '' : 's'} selected',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _evidence.length,
              itemBuilder: (context, index) {
                return _buildEvidencePreview(
                  _evidence[index],
                  index,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }
}