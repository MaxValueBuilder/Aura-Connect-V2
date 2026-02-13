import 'package:aura/screens/consultation/widgets/consultation_progress_indicator.dart';
import 'package:aura/screens/consultation/widgets/label_chip.dart';
import 'package:aura/screens/dashboard/widgets/app_bar_icon_button.dart';
import 'package:aura/screens/widgets/logout_button.dart';
import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/patient_utils.dart';
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
  bool _isEditingHandout = false;
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
    _tabController = TabController(length: 3, vsync: this);
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
    }
  }

  Future<void> _handleSaveHandout() async {
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
    if (_tabController.index == 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Billing has no content to share'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
      return;
    }
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

  Future<void> _exportContentWithText(
    String text, {
    required bool isHandout,
  }) async {
    try {
      final result = await PatientUtils.shareSoapOrHandoutAsFile(
        text: text,
        patientName: widget.patientName,
        isHandout: isHandout,
      );
      if (!mounted) return;
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exported successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export cancelled'),
            backgroundColor: AppColors.textSecondary,
            duration: Duration(seconds: 2),
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
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/logo.svg',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Text(
              'Aura Connect',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [const LogoutButton(), const SizedBox(width: 16)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withAlpha(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Final Consult',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'Fraunces',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Step 4 of 4',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConsultationProgressIndicator(value: 4 / 4),
                          const SizedBox(height: 16),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryIconButton(
                                      onPressed: () {},
                                      icon: Icons.edit,
                                      text: 'Tasks & lab ',
                                      fontSize: 14,
                                      verticalPadding: 14,
                                      enabled: true,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: PrimaryIconButton(
                                      onPressed: () {},
                                      icon: Icons.chat_bubble_outline,
                                      text: 'Initial Recording',
                                      fontSize: 14,
                                      verticalPadding: 14,
                                      enabled: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  LabelChip(
                                    label: 'INITIAL CONSULT',
                                    textColor: AppColors.primary,
                                    backgroundColor: AppColors.primaryLight
                                        .withValues(alpha: 0.1),
                                  ),
                                  LabelChip(
                                    label: 'Final Recorded',
                                    textColor: const Color(0xFF5F9C75),
                                    backgroundColor: const Color(0xFFDCFCE7),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(200),
                            width: 1.5,
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.gray100,
                              width: 2,
                            ),
                            color: AppColors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          tabs: const [
                            Tab(text: 'SOAP Note'),
                            Tab(text: 'Client Handout'),
                            Tab(text: 'Billing'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // SOAP Note Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildSoapNoteCard(),
                    ),
                    // Client Handout Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: _clientHandout == null && !_isEditingHandout
                          ? Center(
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
                          : _buildClientHandoutCard(),
                    ),
                    // Billing Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildBillingCard(),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bottomActionButton(
                    label: 'Export SOAP',
                    icon: Icons.download_outlined,
                    backgroundColor: const Color(0xFFE8E0F5),
                    borderColor: const Color(0xFF9B87C4),
                    foregroundColor: const Color(0xFF6B5B95),
                    onPressed: () => _exportContentWithText(
                      _getSoapText(),
                      isHandout: false,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _bottomActionButton(
                    label: 'Share',
                    icon: Icons.share_outlined,
                    backgroundColor: const Color(0xFFF5E0F0),
                    borderColor: const Color(0xFFC49BB4),
                    foregroundColor: const Color(0xFF9B6B8B),
                    onPressed: () => _shareContent(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _bottomActionButton(
                    label: 'Export Handout',
                    icon: Icons.download_outlined,
                    backgroundColor: const Color(0xFFD4EDDA),
                    borderColor: const Color(0xFF5F9C75),
                    foregroundColor: const Color(0xFF2D6A3E),
                    onPressed: () => _exportContentWithText(
                      _getHandoutText(),
                      isHandout: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _bottomActionButton(
                    label: 'Print All',
                    icon: Icons.print_outlined,
                    backgroundColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    filled: true,
                    onPressed: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Print not available'),
                            backgroundColor: AppColors.textSecondary,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color foregroundColor,
    bool filled = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20, color: foregroundColor),
              label: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20, color: foregroundColor),
              label: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                side: BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
    );
  }

  Widget _buildSoapNoteCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/soap_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'SOAP Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Fraunces',
                    ),
                  ),
                ),
                if (_isEditing) ...[
                  _outlinedIconButton(
                    icon: Icons.close,
                    onPressed: () => setState(() => _handleCancel()),
                  ),
                  const SizedBox(width: 8),
                  _outlinedIconButton(
                    icon: Icons.save_outlined,
                    onPressed: () async => await _handleSave(),
                  ),
                ] else ...[
                  _outlinedIconButton(
                    icon: Icons.edit,
                    onPressed: () => setState(() => _handleEdit()),
                  ),
                  const SizedBox(width: 8),
                  _outlinedIconButton(
                    icon: Icons.copy,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _getSoapText()));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('SOAP note copied to clipboard'),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _buildSoapSection(
              title: 'SUBJECTIVE',
              icon: Icons.record_voice_over,
              controller: _subjectiveController,
              isEditing: _isEditing,
              placeholder:
                  'Subjective:\n- Patient presents with [symptoms]\n- Owner reports [observations]',
              inCard: false,
            ),
            const SizedBox(height: 16),
            _buildSoapSection(
              title: 'OBJECTIVE',
              icon: Icons.visibility,
              controller: _objectiveController,
              isEditing: _isEditing,
              placeholder:
                  'Objective:\nT: [temperature]  BCS: [body condition score]  PE:BAR\n\nEars: [ear findings]\nEyes: [eye findings]\nGI/Abdominal Palpation: [abdominal findings]\nHeart/Cardiovascular: [cardiac findings]\nLungs/Trachea: [respiratory findings]\nLymph nodes/Thyroid gland: [lymph node findings]\nMouth/Teeth/Gums: [oral findings]\nMusculoskeletal: [musculoskeletal findings]\nNervous System: [neurological findings]\nNose/Throat: [nasal/throat findings]\nSkin/Haircoat: [dermatological findings]\nUrinary/Reproductive: [urogenital findings]',
              minLines: 8,
              inCard: false,
            ),
            const SizedBox(height: 16),
            _buildSoapSection(
              title: 'ASSESSMENT',
              icon: Icons.assessment,
              controller: _assessmentController,
              isEditing: _isEditing,
              placeholder:
                  'Assessment:\n- Primary diagnosis: [specific diagnosis]\n- Differential diagnoses: [list of differentials]',
              inCard: false,
            ),
            const SizedBox(height: 16),
            _buildSoapSection(
              title: 'PLAN',
              icon: Icons.assignment,
              controller: _planController,
              isEditing: _isEditing,
              placeholder:
                  'Plan:\n- Treatment recommendations: [specific treatments]\n- Follow-up instructions: [specific follow-up plan]',
              inCard: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientHandoutCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/handout_icon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.black,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Client Handout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Fraunces',
                    ),
                  ),
                ),
                if (_isEditingHandout) ...[
                  _outlinedIconButton(
                    icon: Icons.close,
                    onPressed: () => setState(() => _handleCancelHandout()),
                  ),
                  const SizedBox(width: 8),
                  _outlinedIconButton(
                    icon: Icons.save_outlined,
                    onPressed: () async => await _handleSaveHandout(),
                  ),
                ] else ...[
                  _outlinedIconButton(
                    icon: Icons.edit,
                    onPressed: () => setState(() => _handleEditHandout()),
                  ),
                  const SizedBox(width: 8),
                  _outlinedIconButton(
                    icon: Icons.copy,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _getHandoutText()));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Client handout copied to clipboard'),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            _buildHandoutSection(
              title: 'Letter Opening & Summary',
              icon: Icons.mail_outline,
              controller: _summaryController,
              isEditing: _isEditingHandout,
              placeholder:
                  'Dear [Owner Name],\n\nI hope this message finds you well. I wanted to follow up on [Pet Name]\'s recent visit to our clinic. [Summary of findings and diagnosis]',
              minLines: 5,
              inCard: false,
            ),
            const SizedBox(height: 16),
            _buildHandoutSection(
              title: 'Home Care Instructions',
              icon: Icons.home,
              controller: _homeCareController,
              isEditing: _isEditingHandout,
              placeholder:
                  'Home Care Instructions:\n\n[Specific home care instructions based on diagnosis]',
              inCard: false,
            ),
            const SizedBox(height: 16),
            _buildHandoutSection(
              title: 'Medication Instructions',
              icon: Icons.medication,
              controller: _medicationsController,
              isEditing: _isEditingHandout,
              placeholder:
                  'Medication Instructions:\n\n[Specific medication instructions if prescribed]',
              inCard: false,
            ),
            const SizedBox(height: 16),
            _buildHandoutSection(
              title: 'Follow-up Requirements',
              icon: Icons.calendar_today,
              controller: _followUpController,
              isEditing: _isEditingHandout,
              placeholder:
                  'Follow-up Requirements:\n\n[Specific follow-up requirements and timeline]',
              inCard: false,
            ),
            const SizedBox(height: 16),
            _buildHandoutSection(
              title: 'Emergency Signs',
              icon: Icons.warning,
              controller: _emergencySignsController,
              isEditing: _isEditingHandout,
              placeholder:
                  'Emergency Signs to Watch For:\n\n[Specific signs to watch for]',
              inCard: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: AppColors.black),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Billing Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Fraunces',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Procedures (suggestions only):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildBillingBullet('Physical Examination (recommendation only)'),
            _buildBillingBullet(
              'Radiographs (if needed to rule out foreign body, recommendation only)',
            ),
            const SizedBox(height: 16),
            Text(
              'Medications (suggestions only):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildBillingBullet(
              'Anti-emetic (if vomiting persists, recommendation only) - As prescribed by veterinarian',
            ),
            const SizedBox(height: 16),
            Text(
              'Pricing is not included here. Please consult with your practice management or billing system for actual charges.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoapSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required String placeholder,
    int minLines = 4,
    bool inCard = true,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              contentPadding: const EdgeInsets.all(8),
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
            padding: const EdgeInsets.all(8),
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
    );
    if (!inCard) return content;
    return Card(child: content);
  }

  Widget _buildHandoutSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required String placeholder,
    int minLines = 4,
    bool inCard = true,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              contentPadding: const EdgeInsets.all(8),
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
            padding: const EdgeInsets.all(8),
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
    );
    if (!inCard) return content;
    return Card(child: content);
  }

  Widget _outlinedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: AppColors.primary),
      style: IconButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
