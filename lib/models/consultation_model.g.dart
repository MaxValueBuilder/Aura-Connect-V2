// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsultationModel _$ConsultationModelFromJson(Map<String, dynamic> json) =>
    ConsultationModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String?,
      patientName: json['patientName'] as String?,
      veterinarianId: json['veterinarianId'] as String?,
      veterinarianName: json['veterinarianName'] as String?,
      status: ConsultationModel._statusFromJson(json['status'] as String?),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      notes: json['notes'] as String?,
      transcript: json['transcript'] as String?,
      aiAnalysis: json['aiAnalysis'] == null
          ? null
          : AIAnalysisModel.fromJson(
              json['aiAnalysis'] as Map<String, dynamic>,
            ),
      symptoms: json['symptoms'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      prescription: json['prescription'] as String?,
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.parse(json['followUpDate'] as String),
      priority: json['priority'] as String,
      isEmergency: json['isEmergency'] as bool,
      recordingUrl: json['recordingUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ConsultationModelToJson(ConsultationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'veterinarianId': instance.veterinarianId,
      'veterinarianName': instance.veterinarianName,
      'status': ConsultationModel._statusToJson(instance.status),
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'notes': instance.notes,
      'transcript': instance.transcript,
      'aiAnalysis': instance.aiAnalysis?.toJson(),
      'symptoms': instance.symptoms,
      'diagnosis': instance.diagnosis,
      'treatment': instance.treatment,
      'prescription': instance.prescription,
      'followUpDate': instance.followUpDate?.toIso8601String(),
      'priority': instance.priority,
      'isEmergency': instance.isEmergency,
      'recordingUrl': instance.recordingUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AIAnalysisModel _$AIAnalysisModelFromJson(Map<String, dynamic> json) =>
    AIAnalysisModel(
      patientName: json['patientName'] as String?,
      breed: json['breed'] as String?,
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      labAnalysis: json['labAnalysis'] == null
          ? null
          : LabAnalysisModel.fromJson(
              json['labAnalysis'] as Map<String, dynamic>,
            ),
      finalTranscript: json['finalTranscript'] as String?,
      documentation: json['documentation'] == null
          ? null
          : DocumentationModel.fromJson(
              json['documentation'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AIAnalysisModelToJson(AIAnalysisModel instance) =>
    <String, dynamic>{
      'patientName': instance.patientName,
      'breed': instance.breed,
      'tasks': instance.tasks?.map((e) => e.toJson()).toList(),
      'labAnalysis': instance.labAnalysis?.toJson(),
      'finalTranscript': instance.finalTranscript,
      'documentation': instance.documentation?.toJson(),
    };

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  title: json['title'] as String,
  description: json['description'] as String?,
  completed: json['completed'] as bool? ?? false,
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'completed': instance.completed,
};

LabAnalysisModel _$LabAnalysisModelFromJson(Map<String, dynamic> json) =>
    LabAnalysisModel(
      summary: json['summary'] as String,
      keyFindings: (json['keyFindings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      flaggedValues: (json['flaggedValues'] as List<dynamic>?)
          ?.map((e) => FlaggedValueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LabAnalysisModelToJson(LabAnalysisModel instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'keyFindings': instance.keyFindings,
      'recommendations': instance.recommendations,
      'flaggedValues': instance.flaggedValues?.map((e) => e.toJson()).toList(),
    };

FlaggedValueModel _$FlaggedValueModelFromJson(Map<String, dynamic> json) =>
    FlaggedValueModel(
      parameter: json['parameter'] as String,
      value: json['value'] as String,
      normal: json['normal'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$FlaggedValueModelToJson(FlaggedValueModel instance) =>
    <String, dynamic>{
      'parameter': instance.parameter,
      'value': instance.value,
      'normal': instance.normal,
      'status': instance.status,
    };

DocumentationModel _$DocumentationModelFromJson(Map<String, dynamic> json) =>
    DocumentationModel(
      soapNote: json['soapNote'] == null
          ? null
          : SOAPNoteModel.fromJson(json['soapNote'] as Map<String, dynamic>),
      clientHandout: json['clientHandout'] == null
          ? null
          : ClientHandoutModel.fromJson(
              json['clientHandout'] as Map<String, dynamic>,
            ),
      billing: json['billing'] == null
          ? null
          : BillingModel.fromJson(json['billing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DocumentationModelToJson(DocumentationModel instance) =>
    <String, dynamic>{
      'soapNote': instance.soapNote?.toJson(),
      'clientHandout': instance.clientHandout?.toJson(),
      'billing': instance.billing?.toJson(),
    };

SOAPNoteModel _$SOAPNoteModelFromJson(Map<String, dynamic> json) =>
    SOAPNoteModel(
      subjective: json['subjective'] as String,
      objective: json['objective'] as String,
      assessment: json['assessment'] as String,
      plan: json['plan'] as String,
    );

Map<String, dynamic> _$SOAPNoteModelToJson(SOAPNoteModel instance) =>
    <String, dynamic>{
      'subjective': instance.subjective,
      'objective': instance.objective,
      'assessment': instance.assessment,
      'plan': instance.plan,
    };

ClientHandoutModel _$ClientHandoutModelFromJson(Map<String, dynamic> json) =>
    ClientHandoutModel(
      summary: json['summary'] as String,
      homeCare: json['homeCare'] as String,
      medications: json['medications'] as String,
      followUp: json['followUp'] as String,
      emergencySigns: json['emergencySigns'] as String,
    );

Map<String, dynamic> _$ClientHandoutModelToJson(ClientHandoutModel instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'homeCare': instance.homeCare,
      'medications': instance.medications,
      'followUp': instance.followUp,
      'emergencySigns': instance.emergencySigns,
    };

BillingModel _$BillingModelFromJson(Map<String, dynamic> json) => BillingModel(
  procedures: (json['procedures'] as List<dynamic>?)
      ?.map((e) => ProcedureModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  medications: (json['medications'] as List<dynamic>?)
      ?.map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BillingModelToJson(BillingModel instance) =>
    <String, dynamic>{
      'procedures': instance.procedures?.map((e) => e.toJson()).toList(),
      'medications': instance.medications?.map((e) => e.toJson()).toList(),
    };

ProcedureModel _$ProcedureModelFromJson(Map<String, dynamic> json) =>
    ProcedureModel(description: json['description'] as String);

Map<String, dynamic> _$ProcedureModelToJson(ProcedureModel instance) =>
    <String, dynamic>{'description': instance.description};

MedicationModel _$MedicationModelFromJson(Map<String, dynamic> json) =>
    MedicationModel(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
    );

Map<String, dynamic> _$MedicationModelToJson(MedicationModel instance) =>
    <String, dynamic>{'name': instance.name, 'dosage': instance.dosage};
