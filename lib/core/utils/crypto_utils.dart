import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Hash a password using SHA-256 (hex).
/// Matches web's hashPassword so server can verify with bcrypt(SHA256(password)).
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
