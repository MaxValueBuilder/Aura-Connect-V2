// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientModel _$PatientModelFromJson(Map<String, dynamic> json) => PatientModel(
  id: json['id'] as String,
  name: json['name'] as String,
  species: json['species'] as String,
  breed: json['breed'] as String?,
  age: (json['age'] as num?)?.toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  ownerName: json['ownerName'] as String,
  ownerPhone: json['ownerPhone'] as String?,
  ownerEmail: json['ownerEmail'] as String?,
  medicalHistory: json['medicalHistory'] as String?,
  microchipNumber: json['microchipNumber'] as String?,
  color: json['color'] as String?,
  gender: json['gender'] as String,
  isActive: json['isActive'] as bool,
  createdAt: PatientModel._dateTimeFromJson(json['createdAt']),
  updatedAt: PatientModel._dateTimeFromJson(json['updatedAt']),
);

Map<String, dynamic> _$PatientModelToJson(PatientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'age': instance.age,
      'weight': instance.weight,
      'ownerName': instance.ownerName,
      'ownerPhone': instance.ownerPhone,
      'ownerEmail': instance.ownerEmail,
      'medicalHistory': instance.medicalHistory,
      'microchipNumber': instance.microchipNumber,
      'color': instance.color,
      'gender': instance.gender,
      'isActive': instance.isActive,
      'createdAt': PatientModel._dateTimeToJson(instance.createdAt),
      'updatedAt': PatientModel._dateTimeToJson(instance.updatedAt),
    };
