// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'role': instance.role,
  'licenseNumber': instance.licenseNumber,
  'specialization': instance.specialization,
  'phone': instance.phone,
  'clinicId': instance.clinicId,
  'avatar': instance.avatar,
  'isActive': instance.isActive,
  'lastLogin': instance.lastLogin?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'emailConsultationCompletion': instance.emailConsultationCompletion,
  'emailSystemAlerts': instance.emailSystemAlerts,
  'emailBillingUpdates': instance.emailBillingUpdates,
  'inAppNotifications': instance.inAppNotifications,
};
