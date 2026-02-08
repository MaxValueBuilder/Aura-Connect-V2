// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  role: json['role'] as String,
  licenseNumber: json['licenseNumber'] as String?,
  specialization: json['specialization'] as String?,
  phone: json['phone'] as String?,
  isActive: json['isActive'] as bool,
  lastLogin: json['lastLogin'] == null
      ? null
      : DateTime.parse(json['lastLogin'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  emailConsultationCompletion:
      json['emailConsultationCompletion'] as bool? ?? true,
  emailSystemAlerts: json['emailSystemAlerts'] as bool? ?? true,
  emailBillingUpdates: json['emailBillingUpdates'] as bool? ?? true,
  inAppNotifications: json['inAppNotifications'] as bool? ?? true,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'role': instance.role,
  'licenseNumber': instance.licenseNumber,
  'specialization': instance.specialization,
  'phone': instance.phone,
  'isActive': instance.isActive,
  'lastLogin': instance.lastLogin?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'emailConsultationCompletion': instance.emailConsultationCompletion,
  'emailSystemAlerts': instance.emailSystemAlerts,
  'emailBillingUpdates': instance.emailBillingUpdates,
  'inAppNotifications': instance.inAppNotifications,
};
