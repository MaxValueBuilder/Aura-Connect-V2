import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionModel {
  @JsonKey(fromJson: _stringFromJsonNullable, defaultValue: '')
  final String id;
  @JsonKey(fromJson: _stringFromJsonNullable, defaultValue: '')
  final String clinicId;
  @JsonKey(fromJson: _stringFromJsonNullable, defaultValue: 'unlimited')
  final String tier;
  @JsonKey(fromJson: _stringFromJsonNullable, defaultValue: 'trial')
  final String status; // 'active', 'trial', 'expired', 'cancelled'
  @JsonKey(fromJson: _stringFromJsonNullable, defaultValue: 'monthly')
  final String billingCycle; // 'monthly', 'yearly'
  @JsonKey(fromJson: _stringFromJson)
  final String amount;
  final String? currency;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? startDate;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? endDate;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? trialEndDate;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;
  final Map<String, dynamic>? features;
  final Map<String, dynamic>? limits;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? createdAt;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? updatedAt;

  SubscriptionModel({
    required this.id,
    required this.clinicId,
    required this.tier,
    required this.status,
    required this.billingCycle,
    required this.amount,
    this.currency,
    this.startDate,
    this.endDate,
    this.trialEndDate,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
    this.features,
    this.limits,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  static String _stringFromJson(dynamic value) {
    if (value == null) {
      return '0.00';
    }
    if (value is String) {
      return value;
    }
    if (value is num) {
      return value.toString();
    }
    return value.toString();
  }

  static String _stringFromJsonNullable(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    if (value is num) {
      return value.toString();
    }
    return value.toString();
  }

  static DateTime? _dateTimeFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.parse(value);
    }
    return value as DateTime?;
  }

  static String? _dateTimeToJsonNullable(DateTime? date) =>
      date?.toIso8601String();
}

@JsonSerializable()
class TrialStatusModel {
  final bool hasSubscription;
  final bool isExpired;
  final int daysRemaining;
  final String status;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? trialEndDate;
  final String tier;

  TrialStatusModel({
    required this.hasSubscription,
    required this.isExpired,
    required this.daysRemaining,
    required this.status,
    this.trialEndDate,
    required this.tier,
  });

  factory TrialStatusModel.fromJson(Map<String, dynamic> json) =>
      _$TrialStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrialStatusModelToJson(this);

  static DateTime? _dateTimeFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.parse(value);
    }
    return value as DateTime?;
  }

  static String? _dateTimeToJsonNullable(DateTime? date) =>
      date?.toIso8601String();
}

@JsonSerializable()
class UsageStatsModel {
  final int users;
  final int patients;
  final int consultations;

  UsageStatsModel({
    required this.users,
    required this.patients,
    required this.consultations,
  });

  factory UsageStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UsageStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$UsageStatsModelToJson(this);
}

@JsonSerializable()
class SubscriptionDataModel {
  final SubscriptionModel subscription;
  final TrialStatusModel trialStatus;
  final Map<String, dynamic> limits;
  final UsageStatsModel currentUsage;
  final Map<String, dynamic> usagePercentage;

  SubscriptionDataModel({
    required this.subscription,
    required this.trialStatus,
    required this.limits,
    required this.currentUsage,
    required this.usagePercentage,
  });

  factory SubscriptionDataModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionDataModelToJson(this);
}

