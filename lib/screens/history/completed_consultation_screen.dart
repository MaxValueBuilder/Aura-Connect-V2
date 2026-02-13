import 'package:aura/screens/widgets/app_bar_logo_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../features/consultation/consultation_cubit.dart';
import '../../models/consultation_model.dart';
import '../consultation/documentation_view.dart';

class CompletedConsultationScreen extends StatefulWidget {
  final String consultationId;

  const CompletedConsultationScreen({super.key, required this.consultationId});

  @override
  State<CompletedConsultationScreen> createState() =>
      _CompletedConsultationScreenState();
}

class _CompletedConsultationScreenState
    extends State<CompletedConsultationScreen> {
  bool _isLoading = true;
  DocumentationModel? _documentation;
  String? _patientName;

  @override
  void initState() {
    super.initState();
    _loadConsultationData();
  }

  Future<void> _loadConsultationData() async {
    setState(() => _isLoading = true);

    try {
      await context.read<ConsultationCubit>().loadConsultation(
        widget.consultationId,
      );

      final state = context.read<ConsultationCubit>().state;
      final consultation = state.currentConsultation;

      if (consultation != null) {
        setState(() {
          _patientName = consultation.patientName ?? 'Unknown Patient';
          _documentation = consultation.aiAnalysis?.documentation;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consultation not found'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('Error loading consultation: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading consultation: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () {
              AppRouter.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                predicate: (route) => false,
              );
            },
          ),
          title: AppBarLogoTitle(),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DocumentationView(
      documentation: _documentation,
      patientName: _patientName ?? 'Unknown Patient',
      showStepBar: false,
      onBack: () {
        AppRouter.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          predicate: (route) => false,
        );
      },
      onSave: (soapData) async {
        try {
          // Update consultation with edited SOAP note
          await context.read<ConsultationCubit>().updateConsultation(
            widget.consultationId,
            {
              'aiAnalysis': {
                'documentation': {
                  'soapNote': soapData.toJson(),
                  'clientHandout': _documentation?.clientHandout?.toJson(),
                  'billing': _documentation?.billing?.toJson(),
                },
              },
            },
          );

          // Update local state
          if (mounted) {
            setState(() {
              _documentation = DocumentationModel(
                soapNote: soapData,
                clientHandout: _documentation?.clientHandout,
                billing: _documentation?.billing,
              );
            });
          }
        } catch (e) {
          developer.log('Error saving SOAP note: $e');
          rethrow;
        }
      },
      onSaveHandout: (handoutData) async {
        try {
          // Update consultation with edited client handout
          await context.read<ConsultationCubit>().updateConsultation(
            widget.consultationId,
            {
              'aiAnalysis': {
                'documentation': {
                  'soapNote': _documentation?.soapNote?.toJson(),
                  'clientHandout': handoutData.toJson(),
                  'billing': _documentation?.billing?.toJson(),
                },
              },
            },
          );

          // Update local state
          if (mounted) {
            setState(() {
              _documentation = DocumentationModel(
                soapNote: _documentation?.soapNote,
                clientHandout: handoutData,
                billing: _documentation?.billing,
              );
            });
          }
        } catch (e) {
          developer.log('Error saving client handout: $e');
          rethrow;
        }
      },
    );
  }
}
