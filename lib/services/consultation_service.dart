import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import '../core/error/exceptions.dart';
import '../models/consultation_model.dart';

/// Service for consultation API calls
class ConsultationService {
  final Dio _dio;

  ConsultationService(this._dio);

  /// Get all consultations with optional filters
  Future<Map<String, dynamic>> getConsultations({
    int page = 1,
    int limit = 10,
    String? status,
    String? priority,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;

      final response = await _dio.get(
        '/consultations',
        queryParameters: queryParams,
      );

      final consultationsList = response.data['consultations'] as List;
      final consultations = consultationsList
          .map(
            (json) => ConsultationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return {
        'consultations': consultations,
        'pagination': response.data['pagination'],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single consultation by ID
  Future<ConsultationModel> getConsultation(String id) async {
    try {
      final response = await _dio.get('/consultations/$id');
      return ConsultationModel.fromJson(response.data['consultation']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new consultation
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
      final response = await _dio.post(
        '/consultations',
        data: {
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
      return ConsultationModel.fromJson(response.data['consultation']);
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
  /// Sends raw audio file like web version - backend expects raw binary data
  Future<Map<String, dynamic>> transcribeAudio(String audioFilePath) async {
    try {
      log('Transcribe audio file path-------: $audioFilePath');

      // Read the audio file as bytes (raw binary data)
      final file = File(audioFilePath);
      final audioBytes = await file.readAsBytes();
      log('Audio file size: ${audioBytes.length} bytes');

      // Determine content type based on file extension
      String contentType = 'audio/m4a'; // Default for .m4a files
      if (audioFilePath.endsWith('.m4a')) {
        contentType = 'audio/m4a';
      } else if (audioFilePath.endsWith('.aac')) {
        contentType = 'audio/aac';
      } else if (audioFilePath.endsWith('.webm')) {
        contentType = 'audio/webm';
      } else if (audioFilePath.endsWith('.mp3')) {
        contentType = 'audio/mpeg';
      }

      log('Sending audio with Content-Type: $contentType');

      // Send raw audio bytes directly (like web version)
      final response = await _dio.post(
        '/speech/transcribe',
        data: audioBytes,
        options: Options(headers: {'Content-Type': contentType}),
      );
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

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message =
          error.response!.data['error'] ??
          error.response!.data['message'] ??
          'An error occurred';

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
