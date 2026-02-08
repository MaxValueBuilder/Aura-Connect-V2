// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] == null
          ? ''
          : SubscriptionModel._stringFromJsonNullable(json['id']),
      clinicId: json['clinicId'] == null
          ? ''
          : SubscriptionModel._stringFromJsonNullable(json['clinicId']),
      tier: json['tier'] == null
          ? 'unlimited'
          : SubscriptionModel._stringFromJsonNullable(json['tier']),
      status: json['status'] == null
          ? 'trial'
          : SubscriptionModel._stringFromJsonNullable(json['status']),
      billingCycle: json['billingCycle'] == null
          ? 'monthly'
          : SubscriptionModel._stringFromJsonNullable(json['billingCycle']),
      amount: SubscriptionModel._stringFromJson(json['amount']),
      currency: json['currency'] as String?,
      startDate: SubscriptionModel._dateTimeFromJsonNullable(json['startDate']),
      endDate: SubscriptionModel._dateTimeFromJsonNullable(json['endDate']),
      trialEndDate: SubscriptionModel._dateTimeFromJsonNullable(
        json['trialEndDate'],
      ),
      stripeSubscriptionId: json['stripeSubscriptionId'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      features: json['features'] as Map<String, dynamic>?,
      limits: json['limits'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: SubscriptionModel._dateTimeFromJsonNullable(json['createdAt']),
      updatedAt: SubscriptionModel._dateTimeFromJsonNullable(json['updatedAt']),
    );

Map<String, dynamic> _$SubscriptionModelToJson(
  SubscriptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'clinicId': instance.clinicId,
  'tier': instance.tier,
  'status': instance.status,
  'billingCycle': instance.billingCycle,
  'amount': instance.amount,
  'currency': instance.currency,
  'startDate': SubscriptionModel._dateTimeToJsonNullable(instance.startDate),
  'endDate': SubscriptionModel._dateTimeToJsonNullable(instance.endDate),
  'trialEndDate': SubscriptionModel._dateTimeToJsonNullable(
    instance.trialEndDate,
  ),
  'stripeSubscriptionId': instance.stripeSubscriptionId,
  'stripeCustomerId': instance.stripeCustomerId,
  'features': instance.features,
  'limits': instance.limits,
  'isActive': instance.isActive,
  'createdAt': SubscriptionModel._dateTimeToJsonNullable(instance.createdAt),
  'updatedAt': SubscriptionModel._dateTimeToJsonNullable(instance.updatedAt),
};

TrialStatusModel _$TrialStatusModelFromJson(Map<String, dynamic> json) =>
    TrialStatusModel(
      hasSubscription: json['hasSubscription'] as bool,
      isExpired: json['isExpired'] as bool,
      daysRemaining: (json['daysRemaining'] as num).toInt(),
      status: json['status'] as String,
      trialEndDate: TrialStatusModel._dateTimeFromJsonNullable(
        json['trialEndDate'],
      ),
      tier: json['tier'] as String,
    );

Map<String, dynamic> _$TrialStatusModelToJson(TrialStatusModel instance) =>
    <String, dynamic>{
      'hasSubscription': instance.hasSubscription,
      'isExpired': instance.isExpired,
      'daysRemaining': instance.daysRemaining,
      'status': instance.status,
      'trialEndDate': TrialStatusModel._dateTimeToJsonNullable(
        instance.trialEndDate,
      ),
      'tier': instance.tier,
    };

UsageStatsModel _$UsageStatsModelFromJson(Map<String, dynamic> json) =>
    UsageStatsModel(
      users: (json['users'] as num).toInt(),
      patients: (json['patients'] as num).toInt(),
      consultations: (json['consultations'] as num).toInt(),
    );

Map<String, dynamic> _$UsageStatsModelToJson(UsageStatsModel instance) =>
    <String, dynamic>{
      'users': instance.users,
      'patients': instance.patients,
      'consultations': instance.consultations,
    };

SubscriptionDataModel _$SubscriptionDataModelFromJson(
  Map<String, dynamic> json,
) => SubscriptionDataModel(
  subscription: SubscriptionModel.fromJson(
    json['subscription'] as Map<String, dynamic>,
  ),
  trialStatus: TrialStatusModel.fromJson(
    json['trialStatus'] as Map<String, dynamic>,
  ),
  limits: json['limits'] as Map<String, dynamic>,
  currentUsage: UsageStatsModel.fromJson(
    json['currentUsage'] as Map<String, dynamic>,
  ),
  usagePercentage: json['usagePercentage'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SubscriptionDataModelToJson(
  SubscriptionDataModel instance,
) => <String, dynamic>{
  'subscription': instance.subscription,
  'trialStatus': instance.trialStatus,
  'limits': instance.limits,
  'currentUsage': instance.currentUsage,
  'usagePercentage': instance.usagePercentage,
};
