import 'package:flutter/foundation.dart';

class DebugUtils {
  static void log(String message) {
    if (kDebugMode) {
      print('[APP] $message');
    }
  }

  static void error(String location, dynamic error) {
    if (kDebugMode) {
      print('[ERROR] $location: $error');
    }
  }

  static void logApiError(String endpoint, dynamic response, dynamic error) {
    if (kDebugMode) {
      print('🔴 API ERROR - $endpoint');
      print('   Response: $response');
      print('   Error: $error');
      print('   Response Type: ${response.runtimeType}');
    }
  }

  static void logApiSuccess(String endpoint, dynamic response) {
    if (kDebugMode) {
      print('🟢 API SUCCESS - $endpoint');
      print('   Response: $response');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  static void http(String method, String endpoint, int statusCode) {
    if (kDebugMode) {
      print('[HTTP] $method $endpoint - Status: $statusCode');
    }
  }
}
