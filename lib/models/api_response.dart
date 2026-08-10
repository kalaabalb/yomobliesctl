import 'package:flutter/foundation.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    try {
      // Handle different response formats
      bool success = false;
      String message = '';
      dynamic data;

      // Check if response has success field
      if (json.containsKey('success')) {
        success = json['success'] as bool? ?? false;
      }

      // Check if response has message field
      if (json.containsKey('message')) {
        message = json['message'] as String? ?? 'Operation completed';
      } else if (json.containsKey('error')) {
        message = json['error'] as String? ?? 'An error occurred';
      }

      // Check if response has data field
      if (json.containsKey('data')) {
        data = json['data'];
      } else {
        // If no data field, use the entire response as data (for some endpoints)
        data = json;
      }

      // Parse the data using the provided function
      T? parsedData;
      if (data != null && fromJsonT != null) {
        try {
          parsedData = fromJsonT(data);
        } catch (parseError) {
          if (kDebugMode) {
            print('Error parsing data in ApiResponse: $parseError');
            print('Data that failed to parse: $data');
          }
          // If parsing fails, return null data but keep success status
          parsedData = null;
        }
      }

      return ApiResponse<T>(
        success: success,
        message: message,
        data: parsedData,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Critical error parsing ApiResponse: $e');
        print('Original JSON: $json');
      }
      return ApiResponse(
        success: false,
        message: 'Failed to process server response',
        data: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data)';
  }
}
