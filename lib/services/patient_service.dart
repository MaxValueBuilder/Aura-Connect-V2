import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';
import '../core/error/exceptions.dart';
import '../models/patient_model.dart';

class PatientService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  PatientService(this._dio, this._storage);

  Future<String?> _getStoredClinicId() async {
    final userJson = await _storage.read(key: AppConstants.userDataKey);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final clinicId = map['clinicId']?.toString();
      return (clinicId != null && clinicId.isNotEmpty) ? clinicId : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<PatientModel>> getPatients({int? limit, int? offset}) async {
    try {
      final clinicId = await _getStoredClinicId();
      if (clinicId == null) {
        throw Exception(
          'User or clinic not set up. Please complete clinic setup and try again.',
        );
      }

      print(
        '🔍 [PatientService] Fetching patients for clinicId: $clinicId',
      );
      final response = await _dio.get(
        '/patients/getpatientsbyclinicid/$clinicId',
      );

      print('🔍 [PatientService] Response status: ${response.statusCode}');

      final patientsList = response.data['patients'] as List<dynamic>? ?? [];
      print('🔍 [PatientService] Patients list length: ${patientsList.length}');

      final patients = <PatientModel>[];
      for (var i = 0; i < patientsList.length; i++) {
        try {
          final json = patientsList[i] as Map<String, dynamic>;
          final patient = PatientModel.fromJson(json);
          patients.add(patient);
        } catch (e, stackTrace) {
          print('❌ [PatientService] Error parsing patient $i: $e');
          print('❌ [PatientService] Stack trace: $stackTrace');
          rethrow;
        }
      }

      print(
        '✅ [PatientService] Successfully parsed ${patients.length} patients',
      );
      return patients;
    } on DioException catch (e) {
      print('❌ [PatientService] DioException: ${e.message}');
      print('❌ [PatientService] Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e, stackTrace) {
      print('❌ [PatientService] Unexpected error: $e');
      print('❌ [PatientService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<PatientModel> getPatient(String id) async {
    try {
      final response = await _dio.get('/patients/$id');
      return PatientModel.fromJson(
        response.data['patient'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PatientModel> createPatient({
    required String name,
    required String species,
    String? breed,
    int? age,
    double? weight,
    required String ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? medicalHistory,
    String? microchipNumber,
    String? color,
    String gender = 'unknown',
    bool isActive = true,
  }) async {
    try {
      final response = await _dio.post(
        '/patients',
        data: {
          'name': name,
          'species': species,
          if (breed != null) 'breed': breed,
          if (age != null) 'age': age,
          if (weight != null) 'weight': weight,
          'ownerName': ownerName,
          if (ownerPhone != null) 'ownerPhone': ownerPhone,
          if (ownerEmail != null) 'ownerEmail': ownerEmail,
          if (medicalHistory != null) 'medicalHistory': medicalHistory,
          if (microchipNumber != null) 'microchipNumber': microchipNumber,
          if (color != null) 'color': color,
          'gender': gender,
          'isActive': isActive,
        },
      );
      return PatientModel.fromJson(
        response.data['patient'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PatientModel> updatePatient(
    String id, {
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
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (species != null) data['species'] = species;
      if (breed != null) data['breed'] = breed;
      if (age != null) data['age'] = age;
      if (weight != null) data['weight'] = weight;
      if (ownerName != null) data['ownerName'] = ownerName;
      if (ownerPhone != null) data['ownerPhone'] = ownerPhone;
      if (ownerEmail != null) data['ownerEmail'] = ownerEmail;
      if (medicalHistory != null) data['medicalHistory'] = medicalHistory;
      if (microchipNumber != null) data['microchipNumber'] = microchipNumber;
      if (color != null) data['color'] = color;
      if (gender != null) data['gender'] = gender;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _dio.put('/patients/$id', data: data);
      return PatientModel.fromJson(
        response.data['patient'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await _dio.delete('/patients/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      final data = error.response!.data;
      String message = 'An error occurred';
      if (data is Map<String, dynamic>) {
        message = (data['error'] ?? data['message'] ?? message) as String;
      } else if (data is String && data.isNotEmpty) {
        message = 'Request failed (${statusCode > 0 ? statusCode : "error"})';
      }

      if (statusCode == 401) {
        return AuthException(message: message, statusCode: statusCode);
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: error.message ?? 'Network error occurred');
  }
}
