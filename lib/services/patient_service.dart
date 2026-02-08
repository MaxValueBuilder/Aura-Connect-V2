import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';
import '../models/patient_model.dart';

class PatientService {
  final Dio _dio;

  PatientService(this._dio);

  Future<List<PatientModel>> getPatients({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      print('🔍 [PatientService] Fetching patients with params: $queryParams');
      final response = await _dio.get(
        '/patients',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🔍 [PatientService] Response status: ${response.statusCode}');
      print('🔍 [PatientService] Response data type: ${response.data.runtimeType}');
      print('🔍 [PatientService] Full response data: ${response.data}');

      final patientsList = response.data['patients'] as List<dynamic>? ?? [];
      print('🔍 [PatientService] Patients list length: ${patientsList.length}');

      final patients = <PatientModel>[];
      for (var i = 0; i < patientsList.length; i++) {
        try {
          final json = patientsList[i] as Map<String, dynamic>;
          print('🔍 [PatientService] Processing patient $i: $json');
          
          // Log each field to identify which one is null
          print('🔍 [PatientService] Patient $i - id: ${json['id']} (type: ${json['id'].runtimeType})');
          print('🔍 [PatientService] Patient $i - name: ${json['name']} (type: ${json['name']?.runtimeType})');
          print('🔍 [PatientService] Patient $i - species: ${json['species']} (type: ${json['species']?.runtimeType})');
          print('🔍 [PatientService] Patient $i - ownerName: ${json['ownerName']} (type: ${json['ownerName']?.runtimeType})');
          print('🔍 [PatientService] Patient $i - gender: ${json['gender']} (type: ${json['gender']?.runtimeType})');
          print('🔍 [PatientService] Patient $i - createdAt: ${json['createdAt']} (type: ${json['createdAt']?.runtimeType})');
          print('🔍 [PatientService] Patient $i - updatedAt: ${json['updatedAt']} (type: ${json['updatedAt']?.runtimeType})');
          
          final patient = PatientModel.fromJson(json);
          patients.add(patient);
          print('✅ [PatientService] Successfully parsed patient $i');
        } catch (e, stackTrace) {
          print('❌ [PatientService] Error parsing patient $i: $e');
          print('❌ [PatientService] Stack trace: $stackTrace');
          print('❌ [PatientService] Patient data: ${patientsList[i]}');
          rethrow;
        }
      }

      print('✅ [PatientService] Successfully parsed ${patients.length} patients');
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
      return PatientModel.fromJson(response.data['patient'] as Map<String, dynamic>);
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
      return PatientModel.fromJson(response.data['patient'] as Map<String, dynamic>);
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
      return PatientModel.fromJson(response.data['patient'] as Map<String, dynamic>);
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
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['error'] ??
          error.response!.data['message'] ??
          'An error occurred';

      if (statusCode == 401) {
        return AuthException(message: message, statusCode: statusCode);
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: error.message ?? 'Network error occurred');
  }
}

