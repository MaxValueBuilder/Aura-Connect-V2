import 'package:aura/screens/widgets/primary_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/consultation_progress_indicator.dart';
import 'widgets/edit_consultation_modal.dart';
import 'widgets/lab_upload_card.dart';
import 'widgets/label_chip.dart';

class TasksLabsView extends StatefulWidget {
  final String patientName;
  final Map<String, dynamic>? extractedPatientInfo;
  final List<dynamic> generatedTasks;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final VoidCallback onContinue;

  /// When set, the Upload Lab Result card is shown and these callbacks are used.
  final VoidCallback? onUploadComplete;
  final void Function(String imageUrl)? onUploadSuccess;

  /// When true, show "Ready for Final Consultation" card; when false, show "Initial Recording Complete" alert.
  final bool labUploadCompleted;

  /// When set, "Edit Name & Priority" opens a modal and save updates the consultation.
  final String? consultationId;
  final String initialPriority;
  final bool initialIsEmergency;
  final String initialNotes;
  final VoidCallback? onConsultationUpdated;

  const TasksLabsView({
    super.key,
    required this.patientName,
    this.extractedPatientInfo,
    this.generatedTasks = const [],
    required this.stepInfo,
    required this.totalSteps,
    required this.onContinue,
    this.onUploadComplete,
    this.onUploadSuccess,
    this.labUploadCompleted = false,
    this.consultationId,
    this.initialPriority = 'medium',
    this.initialIsEmergency = false,
    this.initialNotes = '',
    this.onConsultationUpdated,
  });

  @override
  State<TasksLabsView> createState() => _TasksLabsViewState();
}

class _TasksLabsViewState extends State<TasksLabsView> {
  late Map<String, bool> _taskStates;

  @override
  void initState() {
    super.initState();
    // Initialize task states from generated tasks
    _taskStates = {};
    for (var i = 0; i < widget.generatedTasks.length; i++) {
      final task = widget.generatedTasks[i];
      final taskId = _getTaskId(task, i);
      _taskStates[taskId] = _getTaskCompleted(task) ?? false;
    }
  }

  String _getTaskId(dynamic task, int index) {
    if (task is Map) {
      return task['id']?.toString() ??
          task['title']?.toString() ??
          index.toString();
    }
    return index.toString();
  }

  bool? _getTaskCompleted(dynamic task) {
    if (task is Map) {
      return task['completed'] as bool?;
    }
    return false;
  }

  String _getTaskTitle(dynamic task) {
    if (task is Map) {
      return task['title']?.toString() ??
          task['task']?.toString() ??
          task['description']?.toString() ??
          task.toString();
    }
    return task.toString();
  }

  String? _getTaskDescription(dynamic task) {
    if (task is Map) {
      return task['description']?.toString();
    }
    return null;
  }

  String? _getTaskAssignee(dynamic task) {
    if (task is Map) {
      return task['assignee']?.toString();
    }
    return null;
  }

  String? _getTaskPriority(dynamic task) {
    if (task is Map) {
      return task['priority']?.toString();
    }
    return null;
  }

  String? _getTaskCategory(dynamic task) {
    if (task is Map) {
      return task['category']?.toString();
    }
    return null;
  }

  void _handleTaskToggle(String taskId) {
    setState(() {
      _taskStates[taskId] = !(_taskStates[taskId] ?? false);
    });
  }

  void _showEditConsultationModal(BuildContext context) {
    if (widget.consultationId == null) return;
    final breed =
        widget.extractedPatientInfo?['breed']?.toString() ?? 'Mixed breed';
    showDialog(
      context: context,
      builder: (ctx) => EditConsultationModal(
        consultationId: widget.consultationId!,
        initialPatientName: widget.patientName,
        initialBreed: breed,
        initialPriority: widget.initialPriority,
        initialIsEmergency: widget.initialIsEmergency,
        initialNotes: widget.initialNotes,
        onSaved: widget.onConsultationUpdated,
      ),
    );
  }

  // void _copyTasksToClipboard() {
  //   final tasksJson = widget.generatedTasks.map((task) {
  //     if (task is Map) {
  //       return task;
  //     }
  //     return {'title': task.toString()};
  //   }).toList();

  //   final jsonString = tasksJson.toString();
  //   Clipboard.setData(ClipboardData(text: jsonString));

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Tasks copied to clipboard'),
  //       duration: Duration(seconds: 2),
  //       backgroundColor: AppColors.success,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: null, // Disabled during tasks
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Step ${widget.stepInfo['step']} of ${widget.totalSteps}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress header (Figma: light blue background)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Testing -INITIAL COMPLETE',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Step ${widget.stepInfo['step']} of ${widget.totalSteps}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConsultationProgressIndicator(
                      value:
                          (widget.stepInfo['step'] as int) / widget.totalSteps,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: screenSize.width * 0.42,
                          child: PrimaryIconButton(
                            onPressed: widget.consultationId != null
                                ? () => _showEditConsultationModal(context)
                                : () {},
                            icon: Icons.edit,
                            text: 'Edit Name & Priority',
                            fontSize: 14,
                            verticalPadding: 12,
                            enabled: widget.consultationId != null,
                          ),
                        ),
                        SizedBox(
                          width: screenSize.width * 0.42,
                          child: PrimaryIconButton(
                            onPressed: widget.onContinue,
                            icon: Icons.chat_bubble_outline,
                            text: 'Go to final consult',
                            fontSize: 14,
                            verticalPadding: 12,
                            enabled: true,
                          ),
                        ),
                        LabelChip(
                          label: 'Needs lab upload',
                          textColor: const Color(0xFF8F5C23),
                          backgroundColor: const Color(0xFFFEFCE8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Padded main content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Before upload: Initial Recording Complete alert; after upload: Ready for Final Consultation card
                    if (widget.labUploadCompleted)
                      // Ready for Final Consultation card (light green) - shown after lab upload
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Ready for Final Consultation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF388E3C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Lab analysis is complete. You can now proceed to the final consultation and generate documentation.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF66BB6A),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: widget.onContinue,
                                icon: const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Complete Consultation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Initial Recording Complete alert (beige) - shown before lab upload
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEFCE8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF8F5C23)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.inProgressStatusText,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Initial Recording Complete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.inProgressStatusText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'The initial consultation has been recorded and transcribed. '
                                    'Please upload lab results to continue with the analysis and final consultation.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.inProgressStatusText
                                          .withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Upload Lab Result card (embedded from lab_upload_view)
                    if (widget.onUploadComplete != null &&
                        widget.onUploadSuccess != null)
                      LabUploadCard(
                        onUploadComplete: widget.onUploadComplete!,
                        onUploadSuccess: widget.onUploadSuccess,
                      ),
                    if (widget.onUploadComplete != null)
                      const SizedBox(height: 24),

                    // Staff Task List Card
                    if (widget.generatedTasks.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: const Text(
                              'Staff Task List',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontFamily: "Fraunces",
                              ),
                            ),
                          ),

                          // Tasks List
                          Column(
                            children: widget.generatedTasks.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final task = entry.value;
                              final taskId = _getTaskId(task, index);
                              final isCompleted = _taskStates[taskId] ?? false;
                              final taskTitle = _getTaskTitle(task);
                              final taskDescription = _getTaskDescription(task);
                              final taskAssignee = _getTaskAssignee(task);
                              final taskPriority = _getTaskPriority(task);
                              final taskCategory = _getTaskCategory(task);

                              return Container(
                                margin: EdgeInsets.only(
                                  bottom:
                                      index < widget.generatedTasks.length - 1
                                      ? 12
                                      : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Checkbox
                                    Checkbox(
                                      value: isCompleted,
                                      onChanged: (value) =>
                                          _handleTaskToggle(taskId),
                                      activeColor: AppColors.primary,
                                    ),
                                    // Task Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Task Title & Status Chip (Chip below title)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  taskTitle,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isCompleted
                                                        ? AppColors
                                                              .textSecondary
                                                        : AppColors.textPrimary,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              LabelChip(
                                                label: isCompleted
                                                    ? 'Complete'
                                                    : 'Pending',
                                                textColor: const Color(
                                                  0xFF8F5C23,
                                                ),
                                                backgroundColor: const Color(
                                                  0xFFFEFCE8,
                                                ),
                                                padding: 4,
                                              ),
                                            ],
                                          ),
                                          // Task Description
                                          if (taskDescription != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              taskDescription,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                          // Task Metadata
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              if (taskAssignee != null)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,

                                                  children: [
                                                    Text(
                                                      "Assigned to:",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                      textAlign: TextAlign.end,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      taskAssignee,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (taskPriority != null)
                                                LabelChip(
                                                  padding: 4,
                                                  label: taskPriority,
                                                  textColor: AppColors.white,
                                                  backgroundColor:
                                                      taskPriority == 'high'
                                                      ? AppColors.error
                                                      : taskPriority == 'medium'
                                                      ? AppColors.black
                                                      : AppColors.gray100,
                                                ),
                                              if (taskCategory != null)
                                                LabelChip(
                                                  padding: 4,
                                                  label: taskCategory,
                                                  textColor:
                                                      AppColors.textSecondary,
                                                  backgroundColor:
                                                      AppColors.gray100,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Status Badge
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],

                    // Next Steps (Figma)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Next Steps',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _nextStepItem(
                            1,
                            'Upload lab result using the form above (optional)',
                          ),
                          _nextStepItem(
                            2,
                            'Complete any remaining initial tasks',
                          ),
                          _nextStepItem(
                            3,
                            'Proceed to final consultation recording',
                          ),
                          _nextStepItem(
                            4,
                            'Generate comprehensive documentation',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextStepItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
