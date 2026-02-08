import 'package:aura/models/consultation_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ConsultationCard({
    super.key,
    required this.consultation,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(consultation.status),
                    child: Icon(
                      _getStatusIcon(consultation.status),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultation.patientName ?? 'Unknown Patient',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${consultation.veterinarianName ?? "Unknown"} • ${consultation.aiAnalysis?.breed ?? "Unknown breed"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(
                      consultation.status.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(consultation.status)
                        .withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _getStatusColor(consultation.status),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(consultation.startTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    if (status.toString().contains('complete') ||
        status.toString().contains('COMPLETE')) {
      return AppColors.success;
    } else if (status.toString().contains('CONSULT')) {
      return AppColors.warning;
    } else {
      return AppColors.info;
    }
  }

  IconData _getStatusIcon(dynamic status) {
    if (status.toString().contains('complete') ||
        status.toString().contains('COMPLETE')) {
      return Icons.check_circle;
    } else if (status.toString().contains('CONSULT')) {
      return Icons.mic;
    } else {
      return Icons.pending;
    }
  }
}

