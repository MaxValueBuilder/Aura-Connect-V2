import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Utilities for species icon asset paths, colors, form validation, and sharing.
/// Uses SVG assets from assets/icons/.
class PatientUtils {
  // --- Form validation ---

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[\d\s\-\(\)\+]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final num = double.tryParse(value);
    if (num == null || num <= 0) {
      return 'Please enter a valid $fieldName';
    }
    return null;
  }

  // --- Species icon and colors ---

  static const String _basePath = 'assets/icons';

  /// Returns the background color for the species icon container.
  static Color getSpeciesBackgroundColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return const Color(0xFFFFEDD5);
      case 'cat':
        return const Color(0xFFF3E8FF);
      case 'bird':
        return const Color(0xFFC5FCD9);
      case 'cow':
        return const Color(0xFFFFE1FB);
      case 'horse':
        return const Color(0xFFFAEEC7);
      case 'rabbit':
        return const Color(0xA1DCE48C); // has alpha
      default:
        return const Color(0xFFFFE4D6);
    }
  }

  /// Returns the display label for the given species.
  static String getSpeciesLabel(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return 'Dog';
      case 'cat':
        return 'Cat';
      case 'bird':
        return 'Bird';
      case 'rabbit':
        return 'Rabbit';
      case 'cow':
        return 'Cow';
      case 'horse':
        return 'Horse';
      default:
        return 'Other';
    }
  }

  /// Returns the SVG asset path for the given species.
  /// Supported: dog, cat, bird, rabbit, cow, horse.
  /// Falls back to default_pet.svg for unknown species.
  static String getSpeciesIconPath(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return '$_basePath/dog.svg';
      case 'cat':
        return '$_basePath/cat.svg';
      case 'bird':
        return '$_basePath/bird.svg';
      case 'rabbit':
        return '$_basePath/rabbit.svg';
      case 'cow':
        return '$_basePath/cow.svg';
      case 'horse':
        return '$_basePath/horse.svg';
      default:
        return '$_basePath/default_pet.svg';
    }
  }

  // --- Share / Export ---

  /// Shares SOAP note or client handout as a text file via system share sheet.
  /// Returns [ShareResult] so the caller can show appropriate UI (success/cancelled).
  static Future<ShareResult> shareSoapOrHandoutAsFile({
    required String text,
    required String patientName,
    required bool isHandout,
  }) async {
    final dateStr = DateTime.now().toString().substring(0, 10).replaceAll('-', '_');
    final fileName = isHandout
        ? 'Client_Handout_${patientName}_$dateStr.txt'
        : 'SOAP_Note_${patientName}_$dateStr.txt';
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(text);
    final xFile = XFile(file.path, mimeType: 'text/plain');
    final result = await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: isHandout
            ? 'Client Handout - $patientName'
            : 'SOAP Note - $patientName',
        files: [xFile],
      ),
    );
    return result;
  }
}
