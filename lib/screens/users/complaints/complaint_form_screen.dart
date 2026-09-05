import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/complaint_category.dart';
import 'complaint_review_screen.dart';

class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({
    super.key,
    this.selectedCategory,
  });

  final ComplaintCategory? selectedCategory;

  @override
  State<ComplaintFormScreen> createState() =>
      _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _titleController = TextEditingController();
  final _platformController = TextEditingController();
  final _locationController = TextEditingController();
  final _suspectController = TextEditingController();
  final _suspectContactController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ==========================================================
  // PICKERS
  // ==========================================================

  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.platform;

  // ==========================================================
  // FORM STATE
  // ==========================================================

  ComplaintCategory? _selectedCategory;
  DateTime? _incidentDate;

  final List<Map<String, dynamic>> _evidenceFiles = [];

  bool _isSubmitting = false;

  // ==========================================================
  // ANIMATION
  // ==========================================================

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ==========================================================
  // HELPERS
  // ==========================================================

  Color get _primaryColor => AppColors.primary;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _selectedCategory = widget.selectedCategory;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _platformController.dispose();
    _locationController.dispose();
    _suspectController.dispose();
    _suspectContactController.dispose();
    _descriptionController.dispose();

    _animationController.dispose();

    super.dispose();
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> _selectIncidentDate() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _incidentDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: _l10n.selectIncidentDate,
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _incidentDate = picked;
    });
  }

  // ==========================================================
  // EVIDENCE PICKER
  // ==========================================================

  Future<void> _showEvidencePicker() async {
    FocusScope.of(context).unfocus();

    if (_evidenceFiles.length >= 5) {
      _showMessage(
        _l10n.maximumEvidenceFiles,
        isError: true,
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              18,
              8,
              18,
              22,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _l10n.addEvidence,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _l10n.attachEvidenceDescription,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // CAMERA
                _EvidenceOption(
                  icon: Icons.camera_alt_outlined,
                  title: _l10n.takePhoto,
                  subtitle:
                  _l10n.captureEvidenceWithCamera,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromCamera();
                  },
                ),

                const SizedBox(height: 10),

                // GALLERY
                _EvidenceOption(
                  icon: Icons.photo_library_outlined,
                  title: _l10n.chooseFromGallery,
                  subtitle: _l10n.selectImages,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFromGallery();
                  },
                ),

                const SizedBox(height: 10),

                // FILE
                _EvidenceOption(
                  icon: Icons.insert_drive_file_outlined,
                  title: _l10n.chooseFile,
                  subtitle: _l10n.selectDocuments,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _pickFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // CAMERA
  // ==========================================================

  Future<void> _pickFromCamera() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();

      await _addXFile(
        file,
        bytes: bytes,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _l10n.cameraCouldNotBeOpened,
        isError: true,
      );
    }
  }

  // ==========================================================
  // GALLERY
  // ==========================================================

  Future<void> _pickFromGallery() async {
    try {
      final files = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (files.isEmpty) {
        return;
      }

      for (final file in files) {
        if (_evidenceFiles.length >= 5) {
          _showMessage(
            _l10n.maximumEvidenceFiles,
            isError: true,
          );
          break;
        }

        final bytes = await file.readAsBytes();

        await _addXFile(
          file,
          bytes: bytes,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _l10n.galleryCouldNotBeOpened,
        isError: true,
      );
    }
  }

  // ==========================================================
  // FILE PICKER
  // ==========================================================

  Future<void> _pickFile() async {
    try {
      final result = await _filePicker.pickFiles(
        allowMultiple: true,
        withData: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'webp',
          'gif',
          'pdf',
          'doc',
          'docx',
          'txt',
        ],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      for (final file in result.files) {
        if (_evidenceFiles.length >= 5) {
          _showMessage(
            _l10n.maximumEvidenceFiles,
            isError: true,
          );
          break;
        }

        Uint8List? bytes = file.bytes;

        if (bytes == null && file.path != null) {
          try {
            bytes = await XFile(
              file.path!,
            ).readAsBytes();
          } catch (_) {
            bytes = null;
          }
        }

        _addEvidence(
          name: file.name,
          path: file.path ?? '',
          bytes: bytes,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _l10n.unableToSelectFile,
        isError: true,
      );
    }
  }

  // ==========================================================
  // ADD XFILE
  // ==========================================================

  Future<void> _addXFile(
      XFile file, {
        Uint8List? bytes,
      }) async {
    try {
      final resolvedBytes =
          bytes ?? await file.readAsBytes();

      _addEvidence(
        name: file.name,
        path: file.path,
        bytes: resolvedBytes,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _l10n.unableToReadSelectedImage,
        isError: true,
      );
    }
  }

  // ==========================================================
  // ADD EVIDENCE
  // ==========================================================

  void _addEvidence({
    required String name,
    required String path,
    required Uint8List? bytes,
  }) {
    if (!mounted) {
      return;
    }

    if (_evidenceFiles.length >= 5) {
      _showMessage(
        _l10n.maximumEvidenceFiles,
        isError: true,
      );
      return;
    }

    final normalizedName = name.trim();

    // ========================================================
    // DUPLICATE CHECK
    // ========================================================

    final exists = _evidenceFiles.any(
          (item) {
        final oldName =
            item['name']?.toString() ?? '';

        final oldPath =
            item['path']?.toString() ?? '';

        return
          (normalizedName.isNotEmpty &&
              oldName == normalizedName) ||
              (path.isNotEmpty &&
                  oldPath == path);
      },
    );

    if (exists) {
      _showMessage(
        _l10n.evidenceAlreadyAttached,
        isError: true,
      );
      return;
    }

    // ========================================================
    // BASE64
    // ========================================================

    String base64Data = '';

    if (bytes != null && bytes.isNotEmpty) {
      base64Data = base64Encode(bytes);
    }

    // ========================================================
    // MIME TYPE
    // ========================================================

    final extension =
    normalizedName.contains('.')
        ? normalizedName
        .split('.')
        .last
        .toLowerCase()
        : '';

    String mimeType =
        'application/octet-stream';

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        mimeType = 'image/jpeg';
        break;

      case 'png':
        mimeType = 'image/png';
        break;

      case 'webp':
        mimeType = 'image/webp';
        break;

      case 'gif':
        mimeType = 'image/gif';
        break;

      case 'pdf':
        mimeType = 'application/pdf';
        break;

      case 'doc':
        mimeType = 'application/msword';
        break;

      case 'docx':
        mimeType =
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        break;

      case 'txt':
        mimeType = 'text/plain';
        break;
    }

    // ========================================================
    // FILE SIZE SAFETY
    // ========================================================

    if (bytes != null &&
        bytes.length > 700 * 1024) {
      _showMessage(
        'File is too large. Please select a smaller file.',
        isError: true,
      );
      return;
    }

    // ========================================================
    // SAVE EVIDENCE
    // ========================================================

    setState(() {
      _evidenceFiles.add({
        'name': normalizedName.isEmpty
            ? _l10n.evidence
            : normalizedName,
        'path': path,
        'bytes': bytes,
        'base64': base64Data,
        'type': mimeType,
      });
    });

    _showMessage(
      _l10n.evidenceAttachedSuccessfully,
    );
  }

  // ==========================================================
  // REMOVE EVIDENCE
  // ==========================================================

  void _removeEvidence(int index) {
    if (index < 0 ||
        index >= _evidenceFiles.length) {
      return;
    }

    setState(() {
      _evidenceFiles.removeAt(index);
    });
  }

  // ==========================================================
  // CONTINUE TO REVIEW
  // ==========================================================

  Future<void> _continueToReview() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting) {
      return;
    }

    // ========================================================
    // FORM VALIDATION
    // ========================================================

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ========================================================
    // CATEGORY VALIDATION
    // ========================================================

    if (_selectedCategory == null) {
      _showMessage(
        _l10n.pleaseSelectComplaintCategory,
        isError: true,
      );
      return;
    }

    // ========================================================
    // DATE VALIDATION
    // ========================================================

    if (_incidentDate == null) {
      _showMessage(
        _l10n.pleaseSelectIncidentDate,
        isError: true,
      );
      return;
    }

    // ========================================================
    // FUTURE DATE CHECK
    // ========================================================

    final now = DateTime.now();

    final selectedDate = DateTime(
      _incidentDate!.year,
      _incidentDate!.month,
      _incidentDate!.day,
    );

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    if (selectedDate.isAfter(today)) {
      _showMessage(
        _l10n.incidentDateCannotBeFuture,
        isError: true,
      );
      return;
    }

    // ========================================================
    // OPEN REVIEW SCREEN
    // ========================================================

    setState(() {
      _isSubmitting = true;
    });

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComplaintReviewScreen(
            // ------------------------------------------------
            // TITLE
            // ------------------------------------------------
            title:
            _titleController.text.trim(),

            // ------------------------------------------------
            // CATEGORY
            // ComplaintReviewScreen expects String
            // ------------------------------------------------
            category: _categoryLabel(
              _selectedCategory!,
            ),

            // ------------------------------------------------
            // USER NAME
            // ------------------------------------------------
            user:
            _nameController.text.trim(),

            // ------------------------------------------------
            // USER EMAIL
            // ------------------------------------------------
            userEmail:
            _emailController.text.trim(),

            // ------------------------------------------------
            // PHONE
            // ------------------------------------------------
            phone:
            _phoneController.text.trim(),

            // ------------------------------------------------
            // DATE
            // ------------------------------------------------
            date: _incidentDate!,

            // ------------------------------------------------
            // PLATFORM
            // ------------------------------------------------
            platform:
            _platformController.text.trim(),

            // ------------------------------------------------
            // LOCATION
            // ------------------------------------------------
            location:
            _locationController.text.trim(),

            // ------------------------------------------------
            // SUSPECT
            // ------------------------------------------------
            suspect:
            _suspectController.text.trim(),

            // ------------------------------------------------
            // SUSPECT CONTACT
            // ------------------------------------------------
            suspectContact:
            _suspectContactController.text.trim(),

            // ------------------------------------------------
            // DESCRIPTION
            // ------------------------------------------------
            description:
            _descriptionController.text.trim(),

            // ------------------------------------------------
            // EVIDENCE
            // ------------------------------------------------
            evidenceFiles:
            List<Map<String, dynamic>>.from(
              _evidenceFiles,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          isError ? Colors.red : null,
        ),
      );
  }

  // ==========================================================
  // CATEGORY LABEL
  // ==========================================================

  String _categoryLabel(
      ComplaintCategory category,
      ) {
    final value = category.name;

    switch (value.toLowerCase()) {
      case 'phishing':
        return 'Phishing';

      case 'onlinefraud':
      case 'online_fraud':
        return 'Online Fraud';

      case 'socialmedia':
      case 'social_media':
        return 'Social Media';

      case 'hacking':
        return 'Hacking';

      case 'identitytheft':
      case 'identity_theft':
        return 'Identity Theft';

      case 'cyberbullying':
      case 'cyber_bullying':
        return 'Cyber Bullying';

      case 'financialfraud':
      case 'financial_fraud':
        return 'Financial Fraud';

      case 'malware':
        return 'Malware';

      default:
        return value;
    }
  }

  // ==========================================================
  // TEXT FIELD
  // ==========================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _l10n.reportCyberCrime,
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Form(
              key: _formKey,
              child: ListView(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  32,
                ),
                children: [
                  _buildHeader(),

                  const SizedBox(height: 24),

                  _buildPersonalInformation(),

                  const SizedBox(height: 20),

                  _buildIncidentInformation(),

                  const SizedBox(height: 20),

                  _buildEvidenceSection(),

                  const SizedBox(height: 28),

                  _buildContinueButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _primaryColor,
            _primaryColor.withValues(
              alpha: 0.82,
            ),
          ],
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
              Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _l10n.reportCyberCrime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _l10n.provideAccurateInformation,
                  style: TextStyle(
                    color:
                    Colors.white.withValues(
                      alpha: 0.86,
                    ),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PERSONAL INFORMATION
  // ==========================================================

  Widget _buildPersonalInformation() {
    return _SectionCard(
      title:
      _l10n.personalInformation,
      subtitle:
      _l10n.provideContactInformation,
      icon:
      Icons.person_outline,
      children: [
        // NAME
        _buildTextField(
          controller: _nameController,
          label: _l10n.fullName,
          hint: _l10n.enterFullName,
          icon:
          Icons.person_outline,
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return _l10n.enterFullName;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        // EMAIL
        _buildTextField(
          controller: _emailController,
          label: _l10n.emailAddress,
          hint: _l10n.enterYourEmail,
          icon:
          Icons.email_outlined,
          keyboardType:
          TextInputType.emailAddress,
          validator: (value) {
            final email =
                value?.trim() ?? '';

            if (email.isEmpty) {
              return _l10n.enterYourEmail;
            }

            final valid = RegExp(
              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
            ).hasMatch(email);

            if (!valid) {
              return _l10n.enterYourEmail;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        // PHONE
        _buildTextField(
          controller: _phoneController,
          label: _l10n.phoneNumber,
          hint: _l10n.phoneNumber,
          icon:
          Icons.phone_outlined,
          keyboardType:
          TextInputType.phone,
        ),
      ],
    );
  }

  // ==========================================================
  // INCIDENT INFORMATION
  // ==========================================================

  Widget _buildIncidentInformation() {
    return _SectionCard(
      title:
      _l10n.incidentInformation,
      subtitle:
      _l10n.tellUsWhatHappened,
      icon:
      Icons.report_problem_outlined,
      children: [
        // TITLE
        _buildTextField(
          controller: _titleController,
          label:
          _l10n.complaintTitle,
          hint:
          _l10n.onlineShoppingFraud,
          icon: Icons.title,
          validator: (value) {
            if (value == null ||
                value.trim().length < 5) {
              return _l10n.complaintTitle;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        // CATEGORY
        DropdownButtonFormField<
            ComplaintCategory>(
          value: _selectedCategory,
          decoration:
          InputDecoration(
            labelText:
            _l10n.complaintCategory,
            hintText:
            _l10n.pleaseSelectCategory,
            prefixIcon:
            const Icon(
              Icons.category_outlined,
            ),
          ),
          items:
          ComplaintCategory.values
              .map(
                (category) =>
                DropdownMenuItem<
                    ComplaintCategory>(
                  value: category,
                  child: Text(
                    _categoryLabel(
                      category,
                    ),
                  ),
                ),
          )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory =
                  value;
            });
          },
          validator: (value) {
            if (value == null) {
              return _l10n
                  .pleaseSelectCategory;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        // PLATFORM
        _buildTextField(
          controller:
          _platformController,
          label:
          _l10n.platform,
          hint:
          _l10n.platformHint,
          icon:
          Icons.devices_outlined,
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return _l10n.platform;
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        // DATE
        InkWell(
          onTap:
          _selectIncidentDate,
          borderRadius:
          BorderRadius.circular(14),
          child: InputDecorator(
            decoration:
            InputDecoration(
              labelText:
              _l10n.incidentDate,
              prefixIcon:
              const Icon(
                Icons
                    .calendar_today_outlined,
              ),
            ),
            child: Text(
              _incidentDate == null
                  ? _l10n
                  .selectIncidentDate
                  : '${_incidentDate!.day.toString().padLeft(2, '0')}/'
                  '${_incidentDate!.month.toString().padLeft(2, '0')}/'
                  '${_incidentDate!.year}',
            ),
          ),
        ),

        const SizedBox(height: 14),

        // LOCATION
        _buildTextField(
          controller:
          _locationController,
          label:
          _l10n.location,
          hint:
          _l10n.cityArea,
          icon:
          Icons.location_on_outlined,
        ),

        const SizedBox(height: 14),

        // SUSPECT
        _buildTextField(
          controller:
          _suspectController,
          label:
          _l10n.suspectAccount,
          hint:
          _l10n.suspectHint,
          icon:
          Icons.person_search_outlined,
        ),

        const SizedBox(height: 14),

        // SUSPECT CONTACT
        _buildTextField(
          controller:
          _suspectContactController,
          label:
          _l10n.suspectContact,
          hint:
          _l10n.suspectContactHint,
          icon:
          Icons.contact_phone_outlined,
        ),

        const SizedBox(height: 14),

        // DESCRIPTION
        _buildTextField(
          controller:
          _descriptionController,
          label:
          _l10n.incidentDescription,
          hint:
          _l10n.explainWhatHappened,
          icon:
          Icons.description_outlined,
          maxLines: 6,
          validator: (value) {
            if (value == null ||
                value.trim().length <
                    20) {
              return _l10n
                  .describeIncidentClearly;
            }

            return null;
          },
        ),
      ],
    );
  }

  // ==========================================================
  // EVIDENCE SECTION
  // ==========================================================

  Widget _buildEvidenceSection() {
    return _SectionCard(
      title: _l10n.evidence,
      subtitle:
      _l10n
          .attachScreenshotsImagesDocuments,
      icon: Icons.attach_file,
      children: [
        InkWell(
          onTap:
          _showEvidencePicker,
          borderRadius:
          BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding:
            const EdgeInsets.all(22),
            decoration:
            BoxDecoration(
              borderRadius:
              BorderRadius.circular(
                18,
              ),
              border:
              Border.all(
                color:
                _primaryColor
                    .withValues(
                  alpha: 0.25,
                ),
              ),
              color:
              _primaryColor
                  .withValues(
                alpha: 0.04,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons
                      .cloud_upload_outlined,
                  size: 42,
                  color:
                  _primaryColor,
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  _l10n.addEvidence,
                  style:
                  const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  _l10n.cameraGalleryFile,
                  style:
                  const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        // SELECTED EVIDENCE
        if (_evidenceFiles.isNotEmpty) ...[
          const SizedBox(height: 16),

          ...List.generate(
            _evidenceFiles.length,
                (index) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child:
                _EvidencePreviewTile(
                  item:
                  _evidenceFiles[
                  index],
                  onRemove: () =>
                      _removeEvidence(
                        index,
                      ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  // ==========================================================
  // CONTINUE BUTTON
  // ==========================================================

  Widget _buildContinueButton() {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: _isSubmitting
            ? null
            : _continueToReview,
        icon: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons
              .arrow_forward_rounded,
        ),
        label: Text(
          _l10n.reviewComplaint,
        ),
      ),
    );
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard
    extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration:
                  BoxDecoration(
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        title,
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        subtitle,
                        style:
                        const TextStyle(
                          color:
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            ...children,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EVIDENCE OPTION
// ============================================================

class _EvidenceOption
    extends StatelessWidget {
  const _EvidenceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return ListTile(
      onTap: onTap,
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      leading: Container(
        width: 46,
        height: 46,
        decoration:
        BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(
            alpha: 0.10,
          ),
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
        child: Icon(
          icon,
          color: Theme.of(context)
              .colorScheme
              .primary,
        ),
      ),
      title: Text(
        title,
        style:
        const TextStyle(
          fontWeight:
          FontWeight.w700,
        ),
      ),
      subtitle:
      Text(subtitle),
      trailing:
      const Icon(
        Icons
            .chevron_right_rounded,
      ),
    );
  }
}

// ============================================================
// EVIDENCE PREVIEW
// ============================================================

class _EvidencePreviewTile
    extends StatelessWidget {
  const _EvidencePreviewTile({
    required this.item,
    required this.onRemove,
  });

  final Map<String, dynamic> item;
  final VoidCallback onRemove;

  bool _isImage(String name) {
    final lower =
    name.toLowerCase();

    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final name =
        item['name']?.toString() ??
            'Evidence';

    final bytes =
    item['bytes'] as Uint8List?;

    final image =
        bytes != null &&
            bytes.isNotEmpty &&
            _isImage(name);

    return Container(
      padding:
      const EdgeInsets.all(12),
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey
              .withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Row(
        children: [
          // ==================================================
          // PREVIEW
          // ==================================================

          Container(
            width: 52,
            height: 52,
            clipBehavior:
            Clip.antiAlias,
            decoration:
            BoxDecoration(
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .primary
                  .withValues(
                alpha: 0.08,
              ),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: image
                ? Image.memory(
              bytes,
              fit:
              BoxFit.cover,
            )
                : Icon(
              Icons
                  .insert_drive_file,
              color:
              Theme.of(
                context,
              )
                  .colorScheme
                  .primary,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // ==================================================
          // FILE NAME
          // ==================================================

          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          // ==================================================
          // REMOVE
          // ==================================================

          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close_rounded,
            ),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}