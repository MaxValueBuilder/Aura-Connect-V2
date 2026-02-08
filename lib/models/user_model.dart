import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? licenseNumber;
  final String? specialization;
  final String? phone;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Notification Preferences
  final bool emailConsultationCompletion;
  final bool emailSystemAlerts;
  final bool emailBillingUpdates;
  final bool inAppNotifications;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.licenseNumber,
    this.specialization,
    this.phone,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.emailConsultationCompletion = true,
    this.emailSystemAlerts = true,
    this.emailBillingUpdates = true,
    this.inAppNotifications = true,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing with default values for required fields
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? 'Unknown',
      lastName: json['lastName']?.toString() ?? 'Unknown',
      role: json['role']?.toString() ?? 'veterinarian',
      licenseNumber: json['licenseNumber']?.toString(),
      specialization: json['specialization']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      lastLogin: json['lastLogin'] != null
          ? (json['lastLogin'] is String
                ? DateTime.tryParse(json['lastLogin'] as String)
                : json['lastLogin'] is DateTime
                ? json['lastLogin'] as DateTime
                : null)
          : null,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
                ? DateTime.tryParse(json['createdAt'] as String) ??
                      DateTime.now()
                : json['createdAt'] is DateTime
                ? json['createdAt'] as DateTime
                : DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is String
                ? DateTime.tryParse(json['updatedAt'] as String) ??
                      DateTime.now()
                : json['updatedAt'] is DateTime
                ? json['updatedAt'] as DateTime
                : DateTime.now())
          : DateTime.now(),
      // Notification Preferences with defaults
      emailConsultationCompletion:
          json['emailConsultationCompletion'] as bool? ?? true,
      emailSystemAlerts: json['emailSystemAlerts'] as bool? ?? true,
      emailBillingUpdates: json['emailBillingUpdates'] as bool? ?? true,
      inAppNotifications: json['inAppNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? licenseNumber,
    String? specialization,
    String? phone,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailConsultationCompletion,
    bool? emailSystemAlerts,
    bool? emailBillingUpdates,
    bool? inAppNotifications,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailConsultationCompletion:
          emailConsultationCompletion ?? this.emailConsultationCompletion,
      emailSystemAlerts: emailSystemAlerts ?? this.emailSystemAlerts,
      emailBillingUpdates: emailBillingUpdates ?? this.emailBillingUpdates,
      inAppNotifications: inAppNotifications ?? this.inAppNotifications,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    role,
    licenseNumber,
    specialization,
    phone,
    isActive,
    lastLogin,
    createdAt,
    updatedAt,
    emailConsultationCompletion,
    emailSystemAlerts,
    emailBillingUpdates,
    inAppNotifications,
  ];
}
