import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../models/consultation_model.dart';

class SOAPView extends StatefulWidget {
  final DocumentationModel? documentation;
  final String patientName;
  final VoidCallback onBack;
  final Function(SOAPNoteModel)? onSave;
  final Function(ClientHandoutModel)? onSaveHandout;

  const SOAPView({
    super.key,
    required this.documentation,
    required this.patientName,
    required this.onBack,
    this.onSave,
    this.onSaveHandout,
  });

  @override
  State<SOAPView> createState() => _SOAPViewState();
}

class _SOAPViewState extends State<SOAPView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isEditingHandout = false;
  bool _isSavingHandout = false;
  late TextEditingController _subjectiveController;
  late TextEditingController _objectiveController;
  late TextEditingController _assessmentController;
  late TextEditingController _planController;
  late TextEditingController _summaryController;
  late TextEditingController _homeCareController;
  late TextEditingController _medicationsController;
  late TextEditingController _followUpController;
  late TextEditingController _emergencySignsController;

  SOAPNoteModel? get _soapNote => widget.documentation?.soapNote;
  ClientHandoutModel? get _clientHandout => widget.documentation?.clientHandout;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _subjectiveController = TextEditingController(
      text: _soapNote?.subjective ?? '',
    );
    _objectiveController = TextEditingController(
      text: _soapNote?.objective ?? '',
    );
    _assessmentController = TextEditingController(
      text: _soapNote?.assessment ?? '',
    );
    _planController = TextEditingController(text: _soapNote?.plan ?? '');
    _summaryController = TextEditingController(
      text: _clientHandout?.summary ?? '',
    );
    _homeCareController = TextEditingController(
      text: _clientHandout?.homeCare ?? '',
    );
    _medicationsController = TextEditingController(
      text: _clientHandout?.medications ?? '',
    );
    _followUpController = TextEditingController(
      text: _clientHandout?.followUp ?? '',
    );
    _emergencySignsController = TextEditingController(
      text: _clientHandout?.emergencySigns ?? '',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    _summaryController.dispose();
    _homeCareController.dispose();
    _medicationsController.dispose();
    _followUpController.dispose();
    _emergencySignsController.dispose();
    super.dispose();
  }

  void _handleEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _handleCancel() {
    setState(() {
      _isEditing = false;
      // Reset to original values
      _subjectiveController.text = _soapNote?.subjective ?? '';
      _objectiveController.text = _soapNote?.objective ?? '';
      _assessmentController.text = _soapNote?.assessment ?? '';
      _planController.text = _soapNote?.plan ?? '';
    });
  }

  void _handleEditHandout() {
    setState(() {
      _isEditingHandout = true;
    });
  }

  void _handleCancelHandout() {
    setState(() {
      _isEditingHandout = false;
      // Reset to original values
      _summaryController.text = _clientHandout?.summary ?? '';
      _homeCareController.text = _clientHandout?.homeCare ?? '';
      _medicationsController.text = _clientHandout?.medications ?? '';
      _followUpController.text = _clientHandout?.followUp ?? '';
      _emergencySignsController.text = _clientHandout?.emergencySigns ?? '';
    });
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updatedSOAP = SOAPNoteModel(
        subjective: _subjectiveController.text.trim(),
        objective: _objectiveController.text.trim(),
        assessment: _assessmentController.text.trim(),
        plan: _planController.text.trim(),
      );

      if (widget.onSave != null) {
        await widget.onSave!(updatedSOAP);
      }

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOAP note saved successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving SOAP note: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleSaveHandout() async {
    setState(() {
      _isSavingHandout = true;
    });

    try {
      final updatedHandout = ClientHandoutModel(
        summary: _summaryController.text.trim(),
        homeCare: _homeCareController.text.trim(),
        medications: _medicationsController.text.trim(),
        followUp: _followUpController.text.trim(),
        emergencySigns: _emergencySignsController.text.trim(),
      );

      if (widget.onSaveHandout != null) {
        await widget.onSaveHandout!(updatedHandout);
      }

      setState(() {
        _isEditingHandout = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client handout saved successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving client handout: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingHandout = false;
        });
      }
    }
  }

  String _getSoapText() {
    return '''
SOAP Note - ${widget.patientName}
Date: ${DateTime.now().toString().substring(0, 10)}

SUBJECTIVE:
${_soapNote?.subjective ?? 'No data'}

OBJECTIVE:
${_soapNote?.objective ?? 'No data'}

ASSESSMENT:
${_soapNote?.assessment ?? 'No data'}

PLAN:
${_soapNote?.plan ?? 'No data'}
''';
  }

  String _getHandoutText() {
    return '''
Client Handout - ${widget.patientName}
Date: ${DateTime.now().toString().substring(0, 10)}

${_clientHandout?.summary ?? 'Dear Pet Owner,\n\nI hope this message finds you well. I wanted to follow up on your pet\'s recent visit to our clinic.'}

${_clientHandout?.homeCare ?? 'Home Care Instructions:\nPlease follow the veterinarian\'s recommendations for home care.'}

${_clientHandout?.medications ?? 'Medication Instructions:\nMedications as prescribed during consultation.'}

${_clientHandout?.followUp ?? 'Follow-up Requirements:\nSchedule follow-up as recommended by veterinarian.'}

${_clientHandout?.emergencySigns ?? 'Emergency Signs to Watch For:\nContact veterinarian if symptoms worsen or new concerns arise.'}
''';
  }

  Future<void> _shareContent() async {
    try {
      final text = _tabController.index == 0
          ? _getSoapText()
          : _getHandoutText();
      final title = _tabController.index == 0
          ? 'SOAP Note - ${widget.patientName}'
          : 'Client Handout - ${widget.patientName}';
      final params = ShareParams(text: text, title: title);

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tabController.index == 0
                  ? 'SOAP note shared successfully'
                  : 'Client handout shared successfully',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportContent() async {
    try {
      final text = _tabController.index == 0
          ? _getSoapText()
          : _getHandoutText();
      final fileName = _tabController.index == 0
          ? 'SOAP_Note_${widget.patientName}_${DateTime.now().toString().substring(0, 10).replaceAll('-', '_')}.txt'
          : 'Client_Handout_${widget.patientName}_${DateTime.now().toString().substring(0, 10).replaceAll('-', '_')}.txt';

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');

      // Write content to file
      await file.writeAsString(text);

      // Create XFile for sharing
      final xFile = XFile(file.path, mimeType: 'text/plain');

      // Share the file - this opens the system share dialog where users can save it
      final result = await Share.shareXFiles(
        [xFile],
        subject: _tabController.index == 0
            ? 'SOAP Note - ${widget.patientName}'
            : 'Client Handout - ${widget.patientName}',
        text: _tabController.index == 0
            ? 'SOAP Note for ${widget.patientName}'
            : 'Client Handout for ${widget.patientName}',
      );

      if (mounted && result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _tabController.index == 0
                  ? 'SOAP note saved successfully'
                  : 'Client handout saved successfully',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_soapNote == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              // Navigate to dashboard
              AppRouter.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                predicate: (route) => false,
              );
            },
          ),
          title: const Text(
            'SOAP Note',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'No SOAP note available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The SOAP note will be generated after\ncompleting the consultation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // Navigate to dashboard
            AppRouter.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              predicate: (route) => false,
            );
          },
        ),
        title: Text(
          "${widget.patientName}'s Summary",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              // Show actions based on current tab and edit state
              final isSOAPTab = _tabController.index == 0;
              final isEditing = isSOAPTab ? _isEditing : _isEditingHandout;
              final isSaving = isSOAPTab ? _isSaving : _isSavingHandout;

              if (!isEditing) {
                // View mode - show Share, Export, and Edit buttons
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: _shareContent,
                      tooltip: isSOAPTab
                          ? 'Share SOAP Note'
                          : 'Share Client Handout',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.download,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: _exportContent,
                      tooltip: isSOAPTab
                          ? 'Export SOAP Note'
                          : 'Export Client Handout',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: isSOAPTab ? _handleEdit : _handleEditHandout,
                      tooltip: 'Edit',
                    ),
                  ],
                );
              } else {
                // Edit mode - show Cancel and Save buttons
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: isSaving
                          ? null
                          : (isSOAPTab ? _handleCancel : _handleCancelHandout),
                      tooltip: 'Cancel',
                    ),
                    IconButton(
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 20,
                            ),
                      onPressed: isSaving
                          ? null
                          : (isSOAPTab ? _handleSave : _handleSaveHandout),
                      tooltip: 'Save',
                    ),
                  ],
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.description, size: 20), text: 'SOAP Note'),
            Tab(icon: Icon(Icons.people, size: 20), text: 'Client Handout'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // SOAP Note Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SUBJECTIVE Section
                  _buildSection(
                    title: 'SUBJECTIVE',
                    icon: Icons.record_voice_over,
                    controller: _subjectiveController,
                    isEditing: _isEditing,
                    placeholder:
                        'Subjective:\n- Patient presents with [symptoms]\n- Owner reports [observations]',
                  ),
                  const SizedBox(height: 24),

                  // OBJECTIVE Section
                  _buildSection(
                    title: 'OBJECTIVE',
                    icon: Icons.visibility,
                    controller: _objectiveController,
                    isEditing: _isEditing,
                    placeholder:
                        'Objective:\nT: [temperature]  BCS: [body condition score]  PE:BAR\n\nEars: [ear findings]\nEyes: [eye findings]\nGI/Abdominal Palpation: [abdominal findings]\nHeart/Cardiovascular: [cardiac findings]\nLungs/Trachea: [respiratory findings]\nLymph nodes/Thyroid gland: [lymph node findings]\nMouth/Teeth/Gums: [oral findings]\nMusculoskeletal: [musculoskeletal findings]\nNervous System: [neurological findings]\nNose/Throat: [nasal/throat findings]\nSkin/Haircoat: [dermatological findings]\nUrinary/Reproductive: [urogenital findings]',
                    minLines: 8,
                  ),
                  const SizedBox(height: 24),

                  // ASSESSMENT Section
                  _buildSection(
                    title: 'ASSESSMENT',
                    icon: Icons.assessment,
                    controller: _assessmentController,
                    isEditing: _isEditing,
                    placeholder:
                        'Assessment:\n- Primary diagnosis: [specific diagnosis]\n- Differential diagnoses: [list of differentials]',
                  ),
                  const SizedBox(height: 24),

                  // PLAN Section
                  _buildSection(
                    title: 'PLAN',
                    icon: Icons.assignment,
                    controller: _planController,
                    isEditing: _isEditing,
                    placeholder:
                        'Plan:\n- Treatment recommendations: [specific treatments]\n- Follow-up instructions: [specific follow-up plan]',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Client Handout Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_clientHandout == null && !_isEditingHandout)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No client handout available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The client handout will be generated after\ncompleting the consultation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Summary Section
                    _buildHandoutSection(
                      title: 'Letter Opening & Summary',
                      icon: Icons.mail_outline,
                      controller: _summaryController,
                      isEditing: _isEditingHandout,
                      placeholder:
                          'Dear [Owner Name],\n\nI hope this message finds you well. I wanted to follow up on [Pet Name]\'s recent visit to our clinic. [Summary of findings and diagnosis]',
                      minLines: 5,
                    ),
                    const SizedBox(height: 24),

                    // Home Care Section
                    _buildHandoutSection(
                      title: 'Home Care Instructions',
                      icon: Icons.home,
                      controller: _homeCareController,
                      isEditing: _isEditingHandout,
                      placeholder:
                          'Home Care Instructions:\n\n[Specific home care instructions based on diagnosis]',
                    ),
                    const SizedBox(height: 24),

                    // Medications Section
                    _buildHandoutSection(
                      title: 'Medication Instructions',
                      icon: Icons.medication,
                      controller: _medicationsController,
                      isEditing: _isEditingHandout,
                      placeholder:
                          'Medication Instructions:\n\n[Specific medication instructions if prescribed]',
                    ),
                    const SizedBox(height: 24),

                    // Follow-up Section
                    _buildHandoutSection(
                      title: 'Follow-up Requirements',
                      icon: Icons.calendar_today,
                      controller: _followUpController,
                      isEditing: _isEditingHandout,
                      placeholder:
                          'Follow-up Requirements:\n\n[Specific follow-up requirements and timeline]',
                    ),
                    const SizedBox(height: 24),

                    // Emergency Signs Section
                    _buildHandoutSection(
                      title: 'Emergency Signs',
                      icon: Icons.warning,
                      controller: _emergencySignsController,
                      isEditing: _isEditingHandout,
                      placeholder:
                          'Emergency Signs to Watch For:\n\n[Specific signs to watch for]',
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required String placeholder,
    int minLines = 4,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isEditing)
              TextField(
                controller: controller,
                maxLines: null,
                minLines: minLines,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.text.isEmpty ? 'No data' : controller.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.text.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandoutSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required String placeholder,
    int minLines = 4,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isEditing)
              TextField(
                controller: controller,
                maxLines: null,
                minLines: minLines,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.text.isEmpty ? 'No data' : controller.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: controller.text.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
