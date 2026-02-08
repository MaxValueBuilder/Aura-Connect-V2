import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class TasksLabsView extends StatefulWidget {
  final String patientName;
  final Map<String, dynamic>? extractedPatientInfo;
  final List<dynamic> generatedTasks;
  final Map<String, dynamic> stepInfo;
  final int totalSteps;
  final VoidCallback onContinue;

  const TasksLabsView({
    super.key,
    required this.patientName,
    this.extractedPatientInfo,
    this.generatedTasks = const [],
    required this.stepInfo,
    required this.totalSteps,
    required this.onContinue,
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

  void _copyTasksToClipboard() {
    final tasksJson = widget.generatedTasks.map((task) {
      if (task is Map) {
        return task;
      }
      return {'title': task.toString()};
    }).toList();

    final jsonString = tasksJson.toString();
    Clipboard.setData(ClipboardData(text: jsonString));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tasks copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.stepInfo['title'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${((widget.stepInfo['step'] as int) / widget.totalSteps * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (widget.stepInfo['step'] as int) / widget.totalSteps,
                    backgroundColor: AppColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.stepInfo['description'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Patient Summary
              if (widget.extractedPatientInfo != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient: ${widget.extractedPatientInfo!['name'] ?? widget.patientName}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.extractedPatientInfo!['breed'] ?? ''} • '
                                '${widget.extractedPatientInfo!['gender'] ?? ''} • '
                                '${widget.extractedPatientInfo!['age'] ?? ''} ${widget.extractedPatientInfo!['ageUnit'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Staff Task List Card
              if (widget.generatedTasks.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Text(
                                  'Staff Task List',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'AI Generated',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary,
                                        ),
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
                            bottom: index < widget.generatedTasks.length - 1
                                ? 12
                                : 0,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox
                              Checkbox(
                                value: isCompleted,
                                onChanged: (value) => _handleTaskToggle(taskId),
                                activeColor: AppColors.primary,
                              ),
                              // Task Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Task Title
                                    Text(
                                      taskTitle,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isCompleted
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                        // decoration: isCompleted
                                        //     ? TextDecoration.lineThrough
                                        //     : TextDecoration.none,
                                      ),
                                    ),
                                    // Task Description
                                    if (taskDescription != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        taskDescription,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                    // Task Metadata
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        if (taskAssignee != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.person_outline,
                                                size: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                taskAssignee,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (taskPriority != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: taskPriority == 'high'
                                                  ? AppColors.error.withOpacity(
                                                      0.1,
                                                    )
                                                  : taskPriority == 'medium'
                                                  ? AppColors.warning
                                                        .withOpacity(0.1)
                                                  : AppColors.gray100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              taskPriority,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: taskPriority == 'high'
                                                    ? AppColors.error
                                                    : taskPriority == 'medium'
                                                    ? AppColors.warning
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        if (taskCategory != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.gray100,
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              taskCategory,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.success.withOpacity(0.1)
                                      : AppColors.gray100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isCompleted ? 'Complete' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isCompleted
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],

              // Tasks Message Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.medical_services,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.generatedTasks.isEmpty
                            ? 'Complete Any Required Tasks'
                            : 'Review Generated Tasks',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.generatedTasks.isEmpty
                            ? 'Use your desktop or tablet to upload lab results, complete tasks, and access the full clinic portal features.'
                            : '${widget.generatedTasks.length} task${widget.generatedTasks.length != 1 ? 's' : ''} have been generated from your consultation. You can review and complete them on your desktop or tablet.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'On mobile, you can proceed directly to the final consultation recording.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onContinue,
                  icon: const Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
