import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../core/error/exceptions.dart';
import '../models/consultation_model.dart';

/// Service for consultation API calls
class ConsultationService {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ConsultationService(this._dio, this._storage);

  /// Get all consultations with optional filters (by clinicId from stored user)
  Future<Map<String, dynamic>> getConsultations({
    int page = 1,
    int limit = 10,
    String? status,
    String? priority,
  }) async {
    try {
      final userPayload = await _getStoredUserForConsultation();
      if (userPayload == null) {
        throw Exception(
          'User or clinic not set up. Please complete clinic setup and try again.',
        );
      }
      final clinicId = userPayload['clinicId'] as String?;
      if (clinicId == null || clinicId.isEmpty) {
        throw Exception(
          'User or clinic not set up. Please complete clinic setup and try again.',
        );
      }

      final response = await _dio.get(
        '/consultations/getconsultations/$clinicId',
      );

      log('Consultations response: ${response.data}');

      final consultationsList = response.data['consultations'] as List? ?? [];
      final consultations = consultationsList
          .map(
            (json) => ConsultationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      // Server returns list only; build pagination for cubit compatibility
      final pagination = <String, dynamic>{
        'page': page,
        'limit': limit,
        'total': consultations.length,
      };

      return {'consultations': consultations, 'pagination': pagination};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single consultation by ID
  Future<ConsultationModel> getConsultation(String id) async {
    try {
      final response = await _dio.get('/consultations/$id');
      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        throw Exception('Server did not return a valid response');
      }
      // Server may return { consultation: row } or { consultation: { data: row, error } } (Supabase)
      dynamic consultationField = raw['consultation'];
      Map<String, dynamic>? consultationJson;
      if (consultationField is Map<String, dynamic>) {
        final inner = consultationField['data'];
        consultationJson = inner is Map<String, dynamic>
            ? inner
            : consultationField;
      }
      if (consultationJson == null || consultationJson.isEmpty) {
        throw Exception('Server did not return consultation');
      }
      consultationJson['id'] ??= id;
      return ConsultationModel.fromJson(consultationJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new consultation.
  /// Includes stored user (clinicId, role) in body so server can validate clinic.
  Future<ConsultationModel> createConsultation({
    String? patientId,
    required String status,
    required DateTime startTime,
    String? priority,
    bool isEmergency = false,
    AIAnalysisModel? aiAnalysis,
  }) async {
    log('Creating consultation with data: $status');
    log('Creating consultation with data: $startTime');
    log('Creating consultation with data: ${aiAnalysis?.toJson()}');
    try {
      final userPayload = await _getStoredUserForConsultation();
      if (userPayload == null) {
        throw Exception(
          'User or clinic not set up. Please complete clinic setup and try again.',
        );
      }

      final response = await _dio.post(
        '/consultations',
        data: {
          'user': userPayload,
          if (patientId != null) 'patientId': patientId,
          'status': status,
          'startTime': startTime.toIso8601String(),
          if (priority != null) 'priority': priority,
          'isEmergency': isEmergency,
          if (aiAnalysis != null) 'aiAnalysis': aiAnalysis.toJson(),
        },
      );
      log('Consultation created: $response');
      return ConsultationModel.fromJson(response.data['consultation']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // / Reads stored user JSON and returns { clinicId, role } for consultation API.
  Future<Map<String, dynamic>?> _getStoredUserForConsultation() async {
    final userJson = await _storage.read(key: AppConstants.userDataKey);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      final clinicId = map['clinicId']?.toString();
      final role = map['role']?.toString();
      final email = map['email']?.toString();
      if (clinicId == null || clinicId.isEmpty) return null;
      return {
        'clinicId': clinicId,
        'role': role ?? 'veterinarian',
        'email': email ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  /// Update consultation
  Future<ConsultationModel> updateConsultation(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      // Handle aiAnalysis merge if it exists
      if (data.containsKey('aiAnalysis') && data['aiAnalysis'] is Map) {
        // The backend will handle merging, but we should structure it correctly
        final aiAnalysisData = data['aiAnalysis'] as Map<String, dynamic>;
        data['aiAnalysis'] = aiAnalysisData;
      }

      final response = await _dio.put('/consultations/$id', data: data);
      final raw = response.data as Map<String, dynamic>?;
      if (raw == null) {
        throw Exception('Server did not return a valid response');
      }
      // Server PUT returns { success, message, consultation } where consultation
      // is the Supabase result { data: row, error, status, ... }. Use the inner row.
      Map<String, dynamic>? consultationJson =
          raw['data'] as Map<String, dynamic>?;
      if (consultationJson == null) {
        final consultationField = raw['consultation'];
        if (consultationField is Map<String, dynamic>) {
          final inner = consultationField['data'];
          consultationJson = inner is Map<String, dynamic>
              ? inner
              : consultationField;
        }
      }
      if (consultationJson == null || consultationJson.isEmpty) {
        log(
          '❌ [updateConsultation] No consultation in response. response.data keys: ${raw.keys.toList()}',
        );
        throw Exception(
          'Server did not return consultation in update response',
        );
      }
      // Ensure id is set (server may return Supabase wrapper that omitted it)
      consultationJson['id'] ??= id;
      return ConsultationModel.fromJson(consultationJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete consultation
  Future<void> deleteConsultation(String id) async {
    try {
      await _dio.delete('/consultations/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Analyze consultation transcript (AI endpoint)
  Future<Map<String, dynamic>> analyzeConsultation(String transcript) async {
    try {
      final response = await _dio.post(
        '/ai/analyze',
        data: {'transcript': transcript},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Extract patient info from transcript (AI endpoint)
  Future<Map<String, dynamic>> extractPatientInfo(String transcript) async {
    try {
      final response = await _dio.post(
        '/ai/extract-patient-info',
        data: {'transcript': transcript},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Analyze lab results (AI endpoint)
  Future<Map<String, dynamic>> analyzeLab(String imageUrl) async {
    try {
      final response = await _dio.post(
        '/ai/analyze-lab',
        data: {'imageUrl': imageUrl},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate SOAP note (AI endpoint)
  Future<Map<String, dynamic>> generateSOAPNote(String transcript) async {
    try {
      final response = await _dio.post(
        '/ai/generate-soap',
        data: {'transcript': transcript},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate tasks from transcript (AI endpoint)
  Future<Map<String, dynamic>> generateTasks(String transcript) async {
    try {
      final response = await _dio.post(
        '/ai/generate-tasks',
        data: {'transcript': transcript},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate patient name from transcript (AI endpoint)
  Future<Map<String, dynamic>> generatePatientName(String transcript) async {
    try {
      final response = await _dio.post(
        '/ai/generate-patient-name',
        data: {'transcript': transcript},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Transcribe audio file (Speech endpoint)
  Future<Map<String, dynamic>> transcribeAudio(String audioFilePath) async {
    try {
      log('Transcribe audio file path-------: $audioFilePath');

      final file = File(audioFilePath);
      final fileName = file.path.split(Platform.pathSeparator).last;
      final fileLength = await file.length();
      log('Audio file size: $fileLength bytes');

      // Server expects multipart/form-data with `audio` field (multer upload.single('audio'))
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFilePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post('/speech/transcribe', data: formData);
      log('Transcribe audio response: $response');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file (File upload endpoint)
  Future<Map<String, dynamic>> uploadFile(
    String filePath,
    String type, // 'audio' or 'image'
  ) async {
    try {
      final file = File(filePath);
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'type': type,
      });

      final response = await _dio.post('/upload/single', data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate multimodal documentation (AI endpoint)
  Future<Map<String, dynamic>> generateMultimodalDocumentation({
    required String initialTranscript,
    String? finalTranscript,
    Map<String, dynamic>? labAnalysis,
    Map<String, dynamic>? patientInfo,
    String? consultationId,
  }) async {
    try {
      final response = await _dio.post(
        '/ai/generate-documentation',
        data: {
          'initialTranscript': initialTranscript,
          if (finalTranscript != null) 'finalTranscript': finalTranscript,
          if (labAnalysis != null) 'labAnalysis': labAnalysis,
          if (patientInfo != null) 'patientInfo': patientInfo,
          if (consultationId != null) 'consultationId': consultationId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors (safe when response.data is HTML or non-JSON)
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode ?? 0;
      final data = error.response!.data;
      String message = 'An error occurred';
      if (data is Map<String, dynamic>) {
        message = (data['error'] ?? data['message'] ?? message).toString();
      } else if (data is String && data.isNotEmpty) {
        message = statusCode == 404
            ? 'Consultation not found'
            : 'Request failed (${statusCode > 0 ? statusCode : "error"})';
      }

      if (statusCode == 401) {
        return AuthException(message: message, statusCode: statusCode);
      }
      if (statusCode == 404) {
        return ServerException(
          message: 'Consultation not found',
          statusCode: statusCode,
        );
      }

      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: error.message ?? 'Network error occurred');
  }
}
