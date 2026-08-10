import 'dart:convert';

import 'package:admin_panal_start/models/product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/admin_user.dart';
import '../models/api_response.dart';
import 'http_services.dart';

class AdminAuthService extends GetxService {
  final HttpService _httpService = Get.find<HttpService>();
  final GetStorage _storage = GetStorage();

  final RxBool isLoggedIn = false.obs;
  final Rxn<AdminUser> currentUser = Rxn<AdminUser>();
  final RxList<AdminUser> adminUsers = <AdminUser>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAuthState();
  }

  void _loadAuthState() {
    final token = _storage.read('auth_token');
    final userData = _storage.read('user_data');

    if (kDebugMode) {
      debugPrint('🔄 [AUTH] Loading authentication state...');
      debugPrint('   - Token exists: ${token != null}');
      debugPrint('   - User data exists: ${userData != null}');
    }

    if (token != null && userData != null) {
      try {
        currentUser.value = AdminUser.fromJson(userData);
        isLoggedIn.value = true;
        _httpService.setAuthorizationHeader(token);

        if (kDebugMode) {
          debugPrint('✅ [AUTH] Authentication state loaded successfully');
          debugPrint('   - User: ${currentUser.value?.username}');
          debugPrint('   - Clearance Level: ${currentUser.value?.clearanceLevel}');
          debugPrint('   - Can manage users: ${canManageUsers()}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [AUTH] Error loading user data: $e');
        }
        _clearAuthData();
      }
    } else {
      if (kDebugMode) {
        debugPrint('❌ [AUTH] No authentication data found in storage');
      }
    }
  }

  Future<ApiResponse<AdminUser>> login(String username, String password) async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        debugPrint('🔐 [AUTH] Attempting admin login...');
        debugPrint('   - Username: $username');
      }

      if (username.isEmpty || password.isEmpty) {
        return ApiResponse(
          success: false,
          message: 'Please enter both username and password',
          data: null,
        );
      }

      final response = await _httpService.addItem(
        endpointUrl: 'admin-users/login',
        itemData: {
          'username': username.trim(),
          'password': password,
        },
      );

      if (kDebugMode) {
        debugPrint('📥 [AUTH] Login response received');
        debugPrint('   - Status: ${response.statusCode}');
      }
      final loginBody = _normalizeResponseBody(response.body);
      if (kDebugMode) {
        debugPrint('   - Success: ${loginBody is Map ? loginBody['success'] : null}');
      }

      if (response.isOk) {
        final responseBody = loginBody;

        // Validate response structure
        if (responseBody is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: 'Invalid server response format. Please try again.',
            data: null,
          );
        }

        if (!responseBody.containsKey('success')) {
          return ApiResponse(
            success: false,
            message: 'Unexpected server response. Please contact support.',
            data: null,
          );
        }

        if (responseBody['success'] == true) {
          final data = responseBody['data'];

          if (data == null) {
            return ApiResponse(
              success: false,
              message: 'No user data received. Please try again.',
              data: null,
            );
          }

          Map<String, dynamic>? userJson;
          String? token;

          if (data is Map<String, dynamic>) {
            token = data['token']?.toString();

            final nestedUser = data['user'];
            if (nestedUser is Map<String, dynamic>) {
              userJson = nestedUser;
            } else if (data.containsKey('_id') ||
                data.containsKey('username')) {
              userJson = data;
            }
          }

          if (userJson == null) {
            return ApiResponse(
              success: false,
              message: 'Incomplete login data. Please try again.',
              data: null,
            );
          }

          final user = AdminUser.fromJson(userJson);
          final effectiveToken = (token != null && token.isNotEmpty)
              ? token
              : 'local-auth-${user.sId ?? user.username ?? DateTime.now().millisecondsSinceEpoch}';

          if (kDebugMode) {
            debugPrint('✅ [AUTH] Login successful!');
            debugPrint('   - User ID: ${user.sId}');
            debugPrint('   - Username: ${user.username}');
            debugPrint('   - Name: ${user.name}');
            debugPrint('   - Clearance Level: ${user.clearanceLevel}');
            debugPrint('   - Is Super Admin: ${user.isSuperAdmin}');
          }

          // Store authentication data securely
          await _storage.write('auth_token', effectiveToken);
          await _storage.write('user_data', user.toJson());

          // Update application state
          currentUser.value = user;
          isLoggedIn.value = true;
          _httpService.setAuthorizationHeader(effectiveToken);

          return ApiResponse(
            success: true,
            message: 'Welcome back, ${user.name ?? user.username}!',
            data: user,
          );
        } else {
          final errorMessage = responseBody['message'] ??
              'Login failed. Please check your credentials.';
          return ApiResponse(
            success: false,
            message: errorMessage,
            data: null,
          );
        }
      } else {
        final errorMessage = _messageFromResponse(
          response.body,
          'Unable to connect to server. Please check your internet connection.',
        );
        return ApiResponse(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AUTH] Login error: $e');
      }
      return ApiResponse(
        success: false,
        message:
            'Connection failed. Please check your internet connection and try again.',
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<AdminUser>> getProfile() async {
    try {
      final response = await _httpService.getItems(
        endpointUrl: 'admin-users/profile',
      );

      if (response.isOk) {
        final responseBody = _normalizeResponseBody(response.body);

        if (responseBody is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: 'Invalid server response format',
            data: null,
          );
        }

        final apiResponse = ApiResponse<AdminUser>.fromJson(
          responseBody,
          (json) => AdminUser.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          currentUser.value = apiResponse.data;
          await _storage.write('user_data', apiResponse.data!.toJson());

          return ApiResponse(
            success: true,
            message: 'Profile updated successfully',
            data: apiResponse.data,
          );
        } else {
          return ApiResponse(
            success: false,
            message: apiResponse.message,
            data: null,
          );
        }
      } else {
        final errorMessage = _messageFromResponse(
          response.body,
          'Failed to load profile information',
        );
        return ApiResponse(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error while loading profile',
        data: null,
      );
    }
  }

  dynamic _normalizeResponseBody(dynamic body) {
    if (body is String) {
      try {
        return json.decode(body);
      } catch (_) {
        return body;
      }
    }

    return body;
  }

  String _messageFromResponse(dynamic body, String fallback) {
    final normalized = _normalizeResponseBody(body);
    if (normalized is Map) {
      return normalized['message']?.toString() ??
          normalized['error']?.toString() ??
          fallback;
    }

    return fallback;
  }

  Future<void> logout({bool showMessage = true}) async {
    if (kDebugMode) {
      debugPrint('🚪 [AUTH] Logging out user: ${currentUser.value?.username}');
    }
    _clearAuthData();

    if (showMessage) {
      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }

    Get.offAllNamed('/login');
  }

  void _clearAuthData() {
    _storage.remove('auth_token');
    _storage.remove('user_data');
    currentUser.value = null;
    isLoggedIn.value = false;
    adminUsers.clear();
    _httpService.clearAuthorizationHeader();

    if (kDebugMode) {
      debugPrint('🧹 [AUTH] Authentication data cleared');
    }
  }

  Future<ApiResponse<List<AdminUser>>> getAdminUsers() async {
    try {
      isLoading.value = true;

      final response = await _httpService.getItems(
        endpointUrl: 'admin-users',
      );

      if (response.isOk) {
        final responseBody = _normalizeResponseBody(response.body);

        if (responseBody is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: 'Server returned unexpected format',
            data: null,
          );
        }

        final apiResponse = ApiResponse<List<AdminUser>>.fromJson(
          responseBody,
          (json) {
            if (json is List) {
              return json
                  .map((item) =>
                      AdminUser.fromJson(item as Map<String, dynamic>))
                  .toList();
            }
            return [];
          },
        );

        if (apiResponse.success && apiResponse.data != null) {
          adminUsers.value = apiResponse.data!;
          return ApiResponse(
            success: true,
            message: 'Loaded ${adminUsers.length} admin users',
            data: adminUsers,
          );
        } else {
          return ApiResponse(
            success: false,
            message: apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'Unable to load user list',
            data: null,
          );
        }
      } else {
        final errorMessage = _messageFromResponse(
          response.body,
          'Unable to connect to server. Please check your connection.',
        );
        return ApiResponse(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AUTH] Get admin users error: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Network error occurred while loading users',
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<AdminUser>> createAdminUser(
      Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;

      // Validate permissions
      if (!canManageUsers()) {
        return ApiResponse(
          success: false,
          message: 'You do not have permission to create admin users',
          data: null,
        );
      }

      final response = await _httpService.addItem(
        endpointUrl: 'admin-users',
        itemData: userData,
      );

      if (response.isOk) {
        final responseBody = _normalizeResponseBody(response.body);

        if (responseBody is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: 'Invalid server response',
            data: null,
          );
        }

        final apiResponse = ApiResponse<AdminUser>.fromJson(
          responseBody,
          (json) => AdminUser.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          await getAdminUsers(); // Refresh the list
          return ApiResponse(
            success: true,
            message: 'Admin user created successfully!',
            data: apiResponse.data,
          );
        } else {
          return ApiResponse(
            success: false,
            message: apiResponse.message,
            data: null,
          );
        }
      } else {
        final errorMessage = _messageFromResponse(
          response.body,
          'Failed to create user account',
        );
        return ApiResponse(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AUTH] Create admin user error: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Failed to create user: $e',
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<AdminUser>> updateAdminUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;

      // Check permissions
      if (!canManageUsers() && userId != getUserId()) {
        return ApiResponse(
          success: false,
          message: 'You can only edit your own profile',
          data: null,
        );
      }

      final response = await _httpService.updateItem(
        endpointUrl: 'admin-users',
        itemId: userId,
        itemData: userData,
      );

      if (response.isOk) {
        final responseBody = _normalizeResponseBody(response.body);

        if (responseBody is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: 'Invalid server response',
            data: null,
          );
        }

        final apiResponse = ApiResponse<AdminUser>.fromJson(
          responseBody,
          (json) => AdminUser.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Update current user if it's their own profile
          if (userId == currentUser.value?.sId) {
            currentUser.value = apiResponse.data;
            await _storage.write('user_data', apiResponse.data!.toJson());
          }

          await getAdminUsers(); // Refresh the list
          return ApiResponse(
            success: true,
            message: 'User profile updated successfully!',
            data: apiResponse.data,
          );
        } else {
          return ApiResponse(
            success: false,
            message: apiResponse.message,
            data: null,
          );
        }
      } else {
        final errorMessage = _messageFromResponse(
          response.body,
          'Failed to update user profile',
        );
        return ApiResponse(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AUTH] Update admin user error: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Failed to update user: $e',
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<void>> deleteAdminUser(String userId) async {
    try {
      isLoading.value = true;

      // Prevent self-deletion
      if (userId == getUserId()) {
        return ApiResponse(
          success: false,
          message: 'You cannot delete your own account',
          data: null,
        );
      }

      // Check permissions
      if (!canManageUsers()) {
        return ApiResponse(
          success: false,
          message: 'You do not have permission to delete admin users',
          data: null,
        );
      }

      final response = await _httpService.deleteItem(
        endpointUrl: 'admin-users',
        itemId: userId,
      );

      if (response.isOk) {
        final responseBody = _normalizeResponseBody(response.body);

        if (responseBody is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: 'Invalid server response',
            data: null,
          );
        }

        final apiResponse = ApiResponse.fromJson(responseBody, null);

        if (apiResponse.success) {
          await getAdminUsers(); // Refresh the list
          return ApiResponse(
            success: true,
            message: 'Admin user deleted successfully',
            data: null,
          );
        } else {
          return ApiResponse(
            success: false,
            message: apiResponse.message,
            data: null,
          );
        }
      } else {
        final errorMessage = _messageFromResponse(
          response.body,
          'Failed to delete user account',
        );
        return ApiResponse(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [AUTH] Delete admin user error: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Failed to delete user: $e',
        data: null,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ========== PERMISSION METHODS ==========

  bool canManageUsers() {
    return currentUser.value?.isSuperAdmin ?? false;
  }

  bool canManageAllContent() {
    return currentUser.value?.isSuperAdmin ?? false;
  }

  bool canEditItem(dynamic item) {
    // Super admin can edit everything
    if (currentUser.value?.isSuperAdmin ?? false) return true;

    final currentUserId = getUserId();
    if (currentUserId == null) return false;

    // Handle different item types
    if (item is Map<String, dynamic>) {
      final createdBy = item['createdBy'];
      if (createdBy is Map) {
        return createdBy['_id']?.toString() == currentUserId;
      }
      return createdBy?.toString() == currentUserId;
    }

    // For Product model
    if (item is Product) {
      return item.createdById == currentUserId;
    }

    // For other models with createdBy field
    if (item.createdBy != null) {
      return item.createdBy.toString() == currentUserId;
    }

    return false;
  }

  bool canDeleteItem(dynamic item) => canEditItem(item);

  bool canViewAnalytics() {
    return currentUser.value?.isSuperAdmin ?? false;
  }

  bool canManageSettings() {
    return currentUser.value?.isSuperAdmin ?? false;
  }

  // ========== HELPER METHODS ==========

  AdminUser? get currentAdmin => currentUser.value;
  List<AdminUser> get allAdminUsers => adminUsers;
  String? getUserId() => currentUser.value?.sId;
  String? getUserName() =>
      currentUser.value?.name ?? currentUser.value?.username;
  String? getUserEmail() => currentUser.value?.email;
  String? getUserClearanceLevel() => currentUser.value?.clearanceLevel;

  bool hasPermission(String requiredLevel) {
    final userLevel = currentUser.value?.clearanceLevel;

    switch (requiredLevel) {
      case 'super_admin':
        return userLevel == 'super_admin';
      case 'admin':
        return userLevel == 'super_admin' || userLevel == 'admin';
      case 'moderator':
        return userLevel == 'super_admin' ||
            userLevel == 'admin' ||
            userLevel == 'moderator';
      default:
        return false;
    }
  }

  // Check if user can perform action on specific resource
  bool canPerform(String action, String resource) {
    switch (action) {
      case 'create':
      case 'read':
      case 'update':
      case 'delete':
        switch (resource) {
          case 'users':
            return canManageUsers();
          case 'products':
          case 'categories':
          case 'brands':
            return hasPermission('admin');
          case 'settings':
            return canManageSettings();
          case 'analytics':
            return canViewAnalytics();
          default:
            return hasPermission('moderator');
        }
      default:
        return false;
    }
  }

  // Get user-friendly role name
  String get userRole {
    switch (currentUser.value?.clearanceLevel) {
      case 'super_admin':
        return 'Super Administrator';
      case 'admin':
        return 'Administrator';
      case 'moderator':
        return 'Moderator';
      default:
        return 'User';
    }
  }

  // Check if session is valid
  bool get isSessionValid {
    return isLoggedIn.value && currentUser.value != null;
  }

  // Force refresh user data
  Future<void> refreshUserData() async {
    await getProfile();
  }
}
