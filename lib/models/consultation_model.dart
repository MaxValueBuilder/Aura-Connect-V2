import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../core/constants/consultation_status.dart';

part 'consultation_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ConsultationModel extends Equatable {
  final String id;
  final String? patientId;
  final String? patientName;
  final String? veterinarianId;
  final String? veterinarianName;
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final ConsultationStatus status;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;
  final String? transcript;
  final AIAnalysisModel? aiAnalysis;
  final String? symptoms;
  final String? diagnosis;
  final String? treatment;
  final String? prescription;
  final DateTime? followUpDate;
  @JsonKey(fromJson: _priorityFromJson)
  final String priority;
  @JsonKey(fromJson: _isEmergencyFromJson)
  final bool isEmergency;
  final String? recordingUrl;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime updatedAt;

  const ConsultationModel({
    required this.id,
    this.patientId,
    this.patientName,
    this.veterinarianId,
    this.veterinarianName,
    required this.status,
    required this.startTime,
    this.endTime,
    this.notes,
    this.transcript,
    this.aiAnalysis,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    this.prescription,
    this.followUpDate,
    required this.priority,
    required this.isEmergency,
    this.recordingUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  static ConsultationStatus _statusFromJson(String? status) {
    if (status == null) return ConsultationStatus.initialConsult;
    return ConsultationStatus.fromApiValue(status);
  }

  static String _statusToJson(ConsultationStatus status) => status.apiValue;

  static String _priorityFromJson(Object? v) =>
      v == null ? 'medium' : (v is String ? v : v.toString());

  static bool _isEmergencyFromJson(Object? v) =>
      v == null ? false : (v is bool ? v : v == true || v == 'true');

  static DateTime _dateTimeFromJson(Object? v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  factory ConsultationModel.fromJson(Map<String, dynamic> json) =>
      _$ConsultationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsultationModelToJson(this);

  ConsultationModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? veterinarianId,
    String? veterinarianName,
    ConsultationStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? transcript,
    AIAnalysisModel? aiAnalysis,
    String? symptoms,
    String? diagnosis,
    String? treatment,
    String? prescription,
    DateTime? followUpDate,
    String? priority,
    bool? isEmergency,
    String? recordingUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConsultationModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      transcript: transcript ?? this.transcript,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      prescription: prescription ?? this.prescription,
      followUpDate: followUpDate ?? this.followUpDate,
      priority: priority ?? this.priority,
      isEmergency: isEmergency ?? this.isEmergency,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    patientName,
    veterinarianId,
    veterinarianName,
    status,
    startTime,
    endTime,
    notes,
    transcript,
    aiAnalysis,
    symptoms,
    diagnosis,
    treatment,
    prescription,
    followUpDate,
    priority,
    isEmergency,
    recordingUrl,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable(explicitToJson: true)
class AIAnalysisModel extends Equatable {
  final String? patientName;
  final String? breed;
  final List<TaskModel>? tasks;
  final LabAnalysisModel? labAnalysis;
  final String? finalTranscript;
  final DocumentationModel? documentation;

  const AIAnalysisModel({
    this.patientName,
    this.breed,
    this.tasks,
    this.labAnalysis,
    this.finalTranscript,
    this.documentation,
  });

  factory AIAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$AIAnalysisModelToJson(this);

  @override
  List<Object?> get props => [
    patientName,
    breed,
    tasks,
    labAnalysis,
    finalTranscript,
    documentation,
  ];
}

@JsonSerializable()
class TaskModel extends Equatable {
  final String title;
  final String? description;
  final bool completed;

  const TaskModel({
    required this.title,
    this.description,
    this.completed = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  TaskModel copyWith({String? title, String? description, bool? completed}) {
    return TaskModel(
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [title, description, completed];
}

@JsonSerializable(explicitToJson: true)
class LabAnalysisModel extends Equatable {
  final String summary;
  final List<String> keyFindings;
  final List<String> recommendations;
  final List<FlaggedValueModel>? flaggedValues;

  const LabAnalysisModel({
    required this.summary,
    required this.keyFindings,
    required this.recommendations,
    this.flaggedValues,
  });

  factory LabAnalysisModel.fromJson(Map<String, dynamic> json) =>
      _$LabAnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$LabAnalysisModelToJson(this);

  @override
  List<Object?> get props => [
    summary,
    keyFindings,
    recommendations,
    flaggedValues,
  ];
}

@JsonSerializable()
class FlaggedValueModel extends Equatable {
  final String parameter;
  final String value;
  final String normal;
  final String status;

  const FlaggedValueModel({
    required this.parameter,
    required this.value,
    required this.normal,
    required this.status,
  });

  factory FlaggedValueModel.fromJson(Map<String, dynamic> json) =>
      _$FlaggedValueModelFromJson(json);

  Map<String, dynamic> toJson() => _$FlaggedValueModelToJson(this);

  @override
  List<Object?> get props => [parameter, value, normal, status];
}

@JsonSerializable(explicitToJson: true)
class DocumentationModel extends Equatable {
  final SOAPNoteModel? soapNote;
  final ClientHandoutModel? clientHandout;
  final BillingModel? billing;

  const DocumentationModel({this.soapNote, this.clientHandout, this.billing});

  factory DocumentationModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentationModelToJson(this);

  @override
  List<Object?> get props => [soapNote, clientHandout, billing];
}

@JsonSerializable()
class SOAPNoteModel extends Equatable {
  final String subjective;
  final String objective;
  final String assessment;
  final String plan;

  const SOAPNoteModel({
    required this.subjective,
    required this.objective,
    required this.assessment,
    required this.plan,
  });

  factory SOAPNoteModel.fromJson(Map<String, dynamic> json) =>
      _$SOAPNoteModelFromJson(json);

  Map<String, dynamic> toJson() => _$SOAPNoteModelToJson(this);

  @override
  List<Object?> get props => [subjective, objective, assessment, plan];
}

@JsonSerializable()
class ClientHandoutModel extends Equatable {
  final String summary;
  final String homeCare;
  final String medications;
  final String followUp;
  final String emergencySigns;

  const ClientHandoutModel({
    required this.summary,
    required this.homeCare,
    required this.medications,
    required this.followUp,
    required this.emergencySigns,
  });

  factory ClientHandoutModel.fromJson(Map<String, dynamic> json) =>
      _$ClientHandoutModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClientHandoutModelToJson(this);

  @override
  List<Object?> get props => [
    summary,
    homeCare,
    medications,
    followUp,
    emergencySigns,
  ];
}

@JsonSerializable(explicitToJson: true)
class BillingModel extends Equatable {
  final List<ProcedureModel>? procedures;
  final List<MedicationModel>? medications;

  const BillingModel({this.procedures, this.medications});

  factory BillingModel.fromJson(Map<String, dynamic> json) =>
      _$BillingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BillingModelToJson(this);

  @override
  List<Object?> get props => [procedures, medications];
}

@JsonSerializable()
class ProcedureModel extends Equatable {
  final String description;

  const ProcedureModel({required this.description});

  factory ProcedureModel.fromJson(Map<String, dynamic> json) =>
      _$ProcedureModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProcedureModelToJson(this);

  @override
  List<Object?> get props => [description];
}

@JsonSerializable()
class MedicationModel extends Equatable {
  final String name;
  final String dosage;

  const MedicationModel({required this.name, required this.dosage});

  factory MedicationModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationModelToJson(this);

  @override
  List<Object?> get props => [name, dosage];
}
