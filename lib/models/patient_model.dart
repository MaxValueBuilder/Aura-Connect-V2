import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patient_model.g.dart';

@JsonSerializable()
class PatientModel extends Equatable {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final double? weight;
  final String ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final String? medicalHistory;
  final String? microchipNumber;
  final String? color;
  final String gender; // 'male' | 'female' | 'unknown'
  final bool isActive;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  const PatientModel({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.weight,
    required this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.medicalHistory,
    this.microchipNumber,
    this.color,
    required this.gender,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing with default values for required fields
    return PatientModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      species: json['species']?.toString() ?? 'Unknown',
      breed: json['breed']?.toString(),
      age: (json['age'] as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      ownerName: json['ownerName']?.toString() ?? 'Unknown Owner',
      ownerPhone: json['ownerPhone']?.toString(),
      ownerEmail: json['ownerEmail']?.toString(),
      medicalHistory: json['medicalHistory']?.toString(),
      microchipNumber: json['microchipNumber']?.toString(),
      color: json['color']?.toString(),
      gender: json['gender']?.toString() ?? 'unknown',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: _dateTimeFromJson(json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => _$PatientModelToJson(this);

  PatientModel copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? age,
    double? weight,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? medicalHistory,
    String? microchipNumber,
    String? color,
    String? gender,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      color: color ?? this.color,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        breed,
        age,
        weight,
        ownerName,
        ownerPhone,
        ownerEmail,
        medicalHistory,
        microchipNumber,
        color,
        gender,
        isActive,
        createdAt,
        updatedAt,
      ];
}

