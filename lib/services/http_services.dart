import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utility/constants.dart';

class HttpService extends GetConnect {
  final String baseUrl = MAIN_URL;
  final GetStorage _storage = GetStorage();
  final RxString _authToken = ''.obs;

  // Add connection timeout constant
  static const Duration _defaultTimeout = Duration(seconds: 60);
  static const Duration _uploadTimeout = Duration(seconds: 120);

  @override
  void onInit() {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = _defaultTimeout;

    // Load stored token
    _loadStoredToken();

    // Add request modifier for auth headers
    httpClient.addRequestModifier<void>((request) {
      if (_authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${_authToken.value}';
      }
      request.headers['Content-Type'] = 'application/json';

      if (kDebugMode) {
        if (kDebugMode) {
          print('🚀 [HTTP] ${request.method.toUpperCase()} ${request.url}');
          if (request.headers['Authorization'] != null) {
            print(
                '   🔐 Auth: Bearer ***${_authToken.value.substring(_authToken.value.length - 6)}');
          }
        }
      }

      return request;
    });

    // Add response modifier for logging
    httpClient.addResponseModifier<void>((request, response) {
      if (kDebugMode) {
        if (kDebugMode) {
          print(
              '📡 [HTTP] ${response.statusCode} ${request.method.toUpperCase()} ${request.url}');
          if (response.statusCode != 200 && response.statusCode != 201) {
            print('   ⚠️  Response: ${response.bodyString}');
          }
        }
      }
      return response;
    });

    super.onInit();
  }

  void _loadStoredToken() {
    final token = _storage.read('auth_token');
    if (token != null && token is String) {
      _authToken.value = token;
    }
  }

  String? get authToken => _authToken.value.isEmpty ? null : _authToken.value;

  void setAuthorizationHeader(String token) {
    if (token.isNotEmpty) {
      _authToken.value = token;
      _storage.write('auth_token', token);
      if (kDebugMode) {
      if (kDebugMode) {
        print('🔐 [AUTH] Token set: ***${token.substring(token.length - 6)}');
      }
      }
    }
  }

  void clearAuthorizationHeader() {
    _authToken.value = '';
    _storage.remove('auth_token');
    if (kDebugMode) {
      if (kDebugMode) {
        print('🔐 [AUTH] Token cleared');
      }
    }
  }

  Response _buildErrorResponse(dynamic error, {String customMessage = ''}) {
    String message = customMessage.isNotEmpty ? customMessage : 'Network error';

    if (error is String) {
      message = error;
    } else {
      // Handle any other error type by converting to string
      message = error.toString();
    }

    if (kDebugMode) {
      if (kDebugMode) {
        print('❌ [HTTP ERROR] $message');
      }
    }

    return Response(
      statusCode: 500,
      statusText: 'Network Error',
      body: {
        'success': false,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Enhanced GET with better error handling
  Future<Response> getItems({
    required String endpointUrl,
    Map<String, dynamic>? query,
    bool showErrors = true,
  }) async {
    try {
      final response = await get('/$endpointUrl', query: query);
      return _handleResponse(response, showErrors: showErrors);
    } catch (e) {
      return _buildErrorResponse(e);
    }
  }

  // Enhanced POST/ADD
  Future<Response> addItem({
    required String endpointUrl,
    required dynamic itemData,
    bool showErrors = true,
  }) async {
    try {
      final response = await post('/$endpointUrl', itemData);
      return _handleResponse(response, showErrors: showErrors);
    } catch (e) {
      return _buildErrorResponse(e);
    }
  }

  Future<Response> postItem({
    required String endpointUrl,
    required dynamic itemData,
    bool showErrors = true,
  }) async {
    return await addItem(
        endpointUrl: endpointUrl, itemData: itemData, showErrors: showErrors);
  }

  // Enhanced PUT/UPDATE
  Future<Response> updateItem({
    required String endpointUrl,
    required String itemId,
    required dynamic itemData,
    bool showErrors = true,
  }) async {
    try {
      final response = await put('/$endpointUrl/$itemId', itemData);
      return _handleResponse(response, showErrors: showErrors);
    } catch (e) {
      return _buildErrorResponse(e);
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
    Map<String, dynamic>? body,
    bool showErrors = true,
  }) async {
    if (kDebugMode) {
      print('🗑️ [HTTP] DELETE request: $endpointUrl/$itemId');
      print('   - Body: ${body?.toString() ?? "null"}');
      print('   - Auth token: ${authToken != null ? "exists" : "missing"}');
    }

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (_authToken.isNotEmpty)
          'Authorization': 'Bearer ${_authToken.value}',
      };

      final response = await request(
        '/$endpointUrl/$itemId',
        'DELETE',
        headers: headers,
        body: body,
      );

      if (kDebugMode) {
        print('🗑️ [HTTP] DELETE response: ${response.statusCode}');
        print('   - Body: ${response.body}');
      }

      return _handleResponse(response, showErrors: showErrors);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HTTP] DELETE error: $e');
      }
      return _buildErrorResponse(e);
    }
  }

  // Enhanced file upload
  Future<Response> uploadFile({
    required String endpointUrl,
    required FormData formData,
    void Function(double)? onUploadProgress,
    bool showErrors = true,
  }) async {
    try {
      // Temporarily increase timeout for uploads
      final originalTimeout = httpClient.timeout;
      httpClient.timeout = _uploadTimeout;

      final response = await post(
        '/$endpointUrl',
        formData,
        contentType: 'multipart/form-data',
        uploadProgress: onUploadProgress,
      );

      // Restore original timeout
      httpClient.timeout = originalTimeout;

      return _handleResponse(response, showErrors: showErrors);
    } catch (e) {
      return _buildErrorResponse(e, customMessage: 'File upload failed: $e');
    }
  }

  Response _handleResponse(Response response, {bool showErrors = true}) {
    if (kDebugMode) {
      print('🔍 [HTTP] Handling response - Status: ${response.statusCode}');
    }

    if (response.statusCode == null) {
      if (kDebugMode) {
        print('❌ [HTTP] No status code - connection issue');
      }
      return _buildErrorResponse('No connection to server');
    }

    // Handle rate limiting errors (429)
    if (response.statusCode == 429) {
      if (kDebugMode) {
        print('⏰ [HTTP] Rate limited - too many requests');
      }
      if (showErrors) {
        Get.snackbar(
          'Too Many Requests',
          'Please wait a moment and try again',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      return response;
    }

    // Handle authentication errors - DON'T AUTO LOGOUT IMMEDIATELY
    if (response.statusCode == 401) {
      if (kDebugMode) {
        print('🔐 [HTTP] 401 Unauthorized response received');
      }

      // Only logout if we're not already on login page
      if (Get.currentRoute != '/login') {
        if (showErrors) {
          Get.snackbar(
            'Session Expired',
            'Please login again',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }

        // Use delayed navigation to avoid context issues
        Future.delayed(Duration(seconds: 2), () {
          if (Get.currentRoute != '/login') {
            if (kDebugMode) {
              print('🔄 [HTTP] Navigating to login due to unauthorized access');
            }
            Get.find<AdminAuthService>().logout(showMessage: false);
          }
        });
      }

      return response;
    }

    // Handle other error status codes
    if (response.statusCode! >= 400) {
      if (kDebugMode) {
        print('⚠️ [HTTP] Error response: ${response.statusCode}');
      }
      if (showErrors) {
        _showErrorSnackbar(response);
      }
    } else {
      if (kDebugMode) {
        print('✅ [HTTP] Success response: ${response.statusCode}');
      }
    }

    return response;
  }

  void _showErrorSnackbar(Response response) {
    String errorMessage = 'An error occurred';

    try {
      if (response.body is Map) {
        errorMessage = response.body['message']?.toString() ??
            response.body['error']?.toString() ??
            response.statusText ??
            'Unknown error';
      }
    } catch (e) {
      errorMessage = response.statusText ?? 'Unknown error';
    }

    // Don't show snackbar for 401 errors (handled above)
    if (errorMessage.isNotEmpty &&
        Get.isSnackbarOpen == false &&
        response.statusCode != 401) {
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Enhanced connection check
  Future<bool> checkConnection() async {
    try {
      final response = await get('/health', query: {
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString()
      });
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('🔗 [CONNECTION] Failed: $e');
        }
      }
      return false;
    }
  }

  // New method for health check with details
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await get('/health');
      if (response.statusCode == 200 && response.body is Map) {
        return response.body as Map<String, dynamic>;
      }
      return {'status': 'unhealthy', 'message': 'Health check failed'};
    } catch (e) {
      return {'status': 'unhealthy', 'message': e.toString()};
    }
  }

  // Method to clear all cached data if needed
  void clearCache() {
    _storage.erase();
    clearAuthorizationHeader();
    if (kDebugMode) {
      if (kDebugMode) {
        print('🧹 [CACHE] All cached data cleared');
      }
    }
  }

  // Add retry mechanism for failed requests
  Future<Response> getItemsWithRetry({
    required String endpointUrl,
    Map<String, dynamic>? query,
    int maxRetries = 3,
    bool showErrors = true,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await getItems(
          endpointUrl: endpointUrl,
          query: query,
          showErrors: showErrors &&
              attempt == maxRetries - 1, // Only show errors on last attempt
        );

        // If rate limited, wait and retry
        if (response.statusCode == 429 && attempt < maxRetries - 1) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        }

        return response;
      } catch (e) {
        if (attempt == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return _buildErrorResponse('Max retries exceeded');
  }
}
