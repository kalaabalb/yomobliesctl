import 'dart:convert';
import 'package:admin_panal_start/services/admin_auth_service.dart';
import '../../models/api_response.dart';
import '../../models/coupon.dart';
import '../../models/my_notification.dart';
import '../../models/order.dart';
import '../../models/poster.dart';
import '../../models/product.dart';
import '../../models/variant_type.dart';
import '../../services/http_services.dart';
import '../../utility/snack_bar_helper.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import '../../../models/category.dart';
import '../../models/brand.dart';
import '../../models/sub_category.dart';
import '../../models/variant.dart';

class DataProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  bool _isInitializing = false;

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<Category> get categories => _filteredCategories;

  List<SubCategory> _allSubCategories = [];
  List<SubCategory> _filteredSubCategories = [];
  List<SubCategory> get subCategories => _filteredSubCategories;

  List<Brand> _allBrands = [];
  List<Brand> _filteredBrands = [];
  List<Brand> get brands => _filteredBrands;

  List<VariantType> _allVariantTypes = [];
  List<VariantType> _filteredVariantTypes = [];
  List<VariantType> get variantTypes => _filteredVariantTypes;

  List<Variant> _allVariants = [];
  List<Variant> _filteredVariants = [];
  List<Variant> get variants => _filteredVariants;

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Product> get products => _filteredProducts;

  List<Coupon> _allCoupons = [];
  List<Coupon> _filteredCoupons = [];
  List<Coupon> get coupons => _filteredCoupons;

  List<Poster> _allPosters = [];
  List<Poster> _filteredPosters = [];
  List<Poster> get posters => _filteredPosters;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Order> get orders => _filteredOrders;

  List<MyNotification> _allNotifications = [];
  List<MyNotification> _filteredNotifications = [];
  List<MyNotification> get notifications => _filteredNotifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DataProvider();

  void initializeAppData({bool forceRefresh = false}) {
    refreshScreenData('Dashboard', forceRefresh: forceRefresh);
  }

  Future<void> initializeData({bool forceRefresh = false}) async {
    await refreshScreenData('Dashboard', forceRefresh: forceRefresh);
  }

  Future<void> refreshScreenData(
    String screenName, {
    bool forceRefresh = false,
  }) async {
    if (_isInitializing) return;

    try {
      _isInitializing = true;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (!_authService.isLoggedIn.value) {
        _errorMessage = 'Authentication required. Please login first.';
        return;
      }

      final normalizedScreen = screenName.toLowerCase();

      if (normalizedScreen == 'dashboard') {
        await Future.wait([
          getAllProduct(),
          getAllCategory(),
          getAllSubCategory(),
          getAllBrands(),
          getAllVariantType(),
        ], eagerError: false);
      } else if (normalizedScreen == 'order' ||
          normalizedScreen == 'paymentverification') {
        await getAllOrders();
      } else if (normalizedScreen == 'category') {
        await getAllCategory();
      } else if (normalizedScreen == 'subcategory') {
        await getAllSubCategory();
      } else if (normalizedScreen == 'brands') {
        await getAllBrands();
      } else if (normalizedScreen == 'varianttype') {
        await getAllVariantType();
      } else if (normalizedScreen == 'variants') {
        await getAllVariant();
      } else if (normalizedScreen == 'poster') {
        await getAllPosters();
      } else if (normalizedScreen == 'notifications') {
        await getAllNotifications();
      } else if (normalizedScreen == 'ratings') {
        await getAllProduct();
      }

      if (kDebugMode) {
        debugDataState();
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh data: ${e.toString()}';
      if (kDebugMode) {
        print('❌ Error refreshing DataProvider: $e');
      }
    } finally {
      _isLoading = false;
      _isInitializing = false;
      notifyListeners();
    }
  }

  String? get _currentUserId => _authService.getUserId();
  bool get _isSuperAdmin => _authService.canManageAllContent();

  Map<String, dynamic> get _baseQueryParams {
    if (_isSuperAdmin) {
      return {};
    } else {
      final currentUserId = _currentUserId;
      if (currentUserId != null) {
        return {'adminId': currentUserId};
      }
      return {};
    }
  }

  void debugDataState() {
    if (kDebugMode) {
      print('🔍 DataProvider Debug:');
      print(
          '   User: ${_authService.getUserName()} (${_authService.getUserClearanceLevel()})');
      print('   All Products: ${_allProducts.length}');
      print('   Filtered Products: ${_filteredProducts.length}');
      print('   All Categories: ${_allCategories.length}');
      print('   All Brands: ${_allBrands.length}');

      if (_allProducts.isNotEmpty) {
        final product = _allProducts.first;
        print('   First Product: ${product.name}');
        print('   Created By: ${product.createdByName}');
        print('   Can Edit: ${_authService.canEditItem(product)}');
      }
    }
  }

  void testConnectivity() async {
    try {
      final response = await service.getItems(endpointUrl: 'health');
      if (kDebugMode) {
        print('🔗 Connection test: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔗 Connection test failed: $e');
      }
    }
  }

  void testConnection() async {
    try {
      await service.getItems(endpointUrl: 'health');
    } catch (e) {
      if (kDebugMode) {
        print('Connection test failed: $e');
      }
    }
  }

  void checkHttpConfiguration() {
    testConnectivity();
  }

  void testProductsAPI() async {
    try {
      final response = await service.getItems(endpointUrl: 'products');

      if (response.isOk) {
        final data = response.body;
        if (data is Map) {
          if (data['data'] is List) {
            final _ = data['data'] as List;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Test Error: $e');
      }
    }
  }

  Future<List<Category>> getAllCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'categories',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredCategories;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredCategories;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredCategories;
      }

      ApiResponse<List<Category>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) =>
            (json as List).map((item) => Category.fromJson(item)).toList(),
      );

      _allCategories = apiResponse.data ?? [];
      _filteredCategories = List.from(_allCategories);

      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllCategory: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load categories');
      }
    }
    return _filteredCategories;
  }

  void filterCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredCategories = List.from(_allCategories);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredCategories = _allCategories.where((category) {
        return (category.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<SubCategory>> getAllSubCategory({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'subCategories',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredSubCategories;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredSubCategories;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredSubCategories;
      }

      ApiResponse<List<SubCategory>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) =>
            (json as List).map((item) => SubCategory.fromJson(item)).toList(),
      );

      _allSubCategories = apiResponse.data ?? [];
      _filteredSubCategories = List.from(_allSubCategories);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllSubCategory: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load subcategories');
      }
    }
    return _filteredSubCategories;
  }

  void filteredSubCategories(String keyword) {
    if (keyword.isEmpty) {
      _filteredSubCategories = List.from(_allSubCategories);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredSubCategories = _allSubCategories.where((SubCategory) {
        return (SubCategory.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Brand>> getAllBrands({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'brands',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredBrands;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredBrands;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredBrands;
      }

      ApiResponse<List<Brand>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) => (json as List).map((item) => Brand.fromJson(item)).toList(),
      );

      _allBrands = apiResponse.data ?? [];
      _filteredBrands = List.from(_allBrands);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllBrands: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load brands');
      }
    }
    return _filteredBrands;
  }

  void filteredBrands(String keyword) {
    if (keyword.isEmpty) {
      _filteredBrands = List.from(_allBrands);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredBrands = _allBrands.where((Brand) {
        return (Brand.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<VariantType>> getAllVariantType({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'variantTypes',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredVariantTypes;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredVariantTypes;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredVariantTypes;
      }

      ApiResponse<List<VariantType>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) =>
            (json as List).map((item) => VariantType.fromJson(item)).toList(),
      );

      _allVariantTypes = apiResponse.data ?? [];
      _filteredVariantTypes = List.from(_allVariantTypes);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllVariantType: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load variant types');
      }
    }
    return _filteredVariantTypes;
  }

  void filterVariantTypes(String keyword) {
    if (keyword.isEmpty) {
      _filteredVariantTypes = List.from(_allVariantTypes);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredVariantTypes = _allVariantTypes.where((VariantType) {
        return (VariantType.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Variant>> getAllVariant({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'variants',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredVariants;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredVariants;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredVariants;
      }

      ApiResponse<List<Variant>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) => (json as List).map((item) => Variant.fromJson(item)).toList(),
      );

      _allVariants = apiResponse.data ?? [];
      _filteredVariants = List.from(_allVariants);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllVariant: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load variants');
      }
    }
    return _filteredVariants;
  }

  void filterVariants(String keyword) {
    if (keyword.isEmpty) {
      _filteredVariants = List.from(_allVariants);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredVariants = _allVariants.where((Variant) {
        return (Variant.name ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Product>> getAllProduct({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'products',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
              'No response from server. Please check your connection.');
        }
        return _filteredProducts;
      }

      dynamic responseBody = response.body;

      if (kDebugMode) {
        print('📥 Products API Raw Response: $responseBody');
      }

      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid server response format.');
          }
          return _filteredProducts;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar(
              'Unexpected server response format.');
        }
        return _filteredProducts;
      }

      ApiResponse<List<Product>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) {
          if (json is List) {
            return json.map((item) => Product.fromJson(item)).toList();
          } else if (json is Map<String, dynamic>) {
            if (json['products'] is List) {
              return (json['products'] as List)
                  .map((item) => Product.fromJson(item))
                  .toList();
            } else if (json['items'] is List) {
              return (json['items'] as List)
                  .map((item) => Product.fromJson(item))
                  .toList();
            }
          }
          return [];
        },
      );

      _allProducts = apiResponse.data ?? [];
      _filteredProducts = List.from(_allProducts);

      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar('Products loaded successfully');
        } else {
          SnackBarHelper.showErrorSnackBar(apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'Unable to load products. Please try again.');
        }
      }

      if (kDebugMode) {
        print('✅ Products loaded: ${_allProducts.length} items');
        if (_allProducts.isNotEmpty) {
          print('📦 First product: ${_allProducts.first.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getAllProduct: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar(
            'Network error. Please check your connection and try again.');
      }
    }
    return _filteredProducts;
  }

  void filterProducts(String keyword) {
    if (keyword.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      final lowcase = keyword.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final ProductNameContainsKeyword =
            (product.name ?? '').toLowerCase().contains(lowcase);
        final categoryNameContainsKeyword =
            product.proCategoryId?.name?.toLowerCase().contains(lowcase) ??
                false;
        final subCategoryNameContainsKeyword =
            product.proSubCategoryId?.name?.toLowerCase().contains(lowcase) ??
                false;
        final brandNameContainsKeyword =
            product.proBrandId?.name?.toLowerCase().contains(lowcase) ?? false;

        return ProductNameContainsKeyword ||
            categoryNameContainsKeyword ||
            subCategoryNameContainsKeyword ||
            brandNameContainsKeyword;
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Coupon>> getAllCoupons({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'couponCodes',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredCoupons;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredCoupons;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredCoupons;
      }

      ApiResponse<List<Coupon>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) => (json as List).map((item) => Coupon.fromJson(item)).toList(),
      );

      _allCoupons = apiResponse.data ?? [];
      _filteredCoupons = List.from(_allCoupons);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllCoupons: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load coupons');
      }
    }
    return _filteredCoupons;
  }

  void filterCoupons(String keyword) {
    if (keyword.isEmpty) {
      _filteredCoupons = List.from(_allCoupons);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredCoupons = _allCoupons.where((coupon) {
        return (coupon.couponCode ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Poster>> getAllPosters({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(
        endpointUrl: 'posters',
        query: _baseQueryParams,
      );

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredPosters;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredPosters;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredPosters;
      }

      ApiResponse<List<Poster>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) => (json as List).map((item) => Poster.fromJson(item)).toList(),
      );

      _allPosters = apiResponse.data ?? [];
      _filteredPosters = List.from(_allPosters);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllPosters: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load posters');
      }
    }
    return _filteredPosters;
  }

  void filterPosters(String keyword) {
    if (keyword.isEmpty) {
      _filteredPosters = List.from(_allPosters);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredPosters = _allPosters.where((poster) {
        return (poster.posterName ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<MyNotification>> getAllNotifications(
      {bool showSnack = false}) async {
    try {
      Response response =
          await service.getItems(endpointUrl: 'notification/all-notification');

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredNotifications;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredNotifications;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredNotifications;
      }

      ApiResponse<List<MyNotification>> apiResponse = ApiResponse.fromJson(
        responseBody,
        (json) => (json as List)
            .map((item) => MyNotification.fromJson(item))
            .toList(),
      );

      _allNotifications = apiResponse.data ?? [];
      _filteredNotifications = List.from(_allNotifications);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllNotifications: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load notifications');
      }
    }
    return _filteredNotifications;
  }

  void filterNotifications(String keyword) {
    if (keyword.isEmpty) {
      _filteredNotifications = List.from(_allNotifications);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredNotifications = _allNotifications.where((notification) {
        return (notification.title ?? '').toLowerCase().contains(lowcase) ||
            (notification.description ?? '').toLowerCase().contains(lowcase);
      }).toList();
    }
    notifyListeners();
  }

  Future<List<Order>> getAllOrders({bool showSnack = false}) async {
    try {
      Response response = await service.getItems(endpointUrl: 'orders');

      if (response.body == null) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('No response from server');
        }
        return _filteredOrders;
      }

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = json.decode(responseBody);
        } catch (e) {
          if (showSnack) {
            SnackBarHelper.showErrorSnackBar('Invalid response format');
          }
          return _filteredOrders;
        }
      }

      if (responseBody is! Map<String, dynamic>) {
        if (showSnack) {
          SnackBarHelper.showErrorSnackBar('Invalid response format');
        }
        return _filteredOrders;
      }

      ApiResponse<List<Order>> apiResponse = ApiResponse<List<Order>>.fromJson(
        responseBody,
        (json) => (json as List).map((item) => Order.fromJson(item)).toList(),
      );

      _allOrders = apiResponse.data ?? [];
      _filteredOrders = List.from(_allOrders);
      notifyListeners();

      if (showSnack && apiResponse.message.isNotEmpty) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getAllOrders: $e');
      }
      if (showSnack) {
        SnackBarHelper.showErrorSnackBar('Failed to load orders');
      }
    }
    return _filteredOrders;
  }

  void filterOrders(String keyword) {
    if (keyword.isEmpty) {
      _filteredOrders = List.from(_allOrders);
    } else {
      final lowcase = keyword.toLowerCase();
      _filteredOrders = _allOrders.where((order) {
        bool nameMatches =
            (order.userID?.name ?? '').toLowerCase().contains(lowcase);
        bool statusMatches =
            (order.orderStatus ?? '').toLowerCase().contains(lowcase);
        return nameMatches || statusMatches;
      }).toList();
    }
    notifyListeners();
  }

  int calculateOrdersWithStatus(String? status) {
    int totalPrdt = 0;

    if (status == null) {
      totalPrdt = _allOrders.length;
    } else {
      for (Order order in _allOrders) {
        if (order.orderStatus == status) {
          totalPrdt += 1;
        }
      }
    }

    return totalPrdt;
  }

  int calculateOrdersWithPaymentStatus(String? status) {
    int total = 0;

    if (status == null) {
      total = _allOrders.length;
    } else {
      for (Order order in _allOrders) {
        if (order.paymentStatus == status) {
          total += 1;
        }
      }
    }

    return total;
  }

  int calculateProductWithQuantity(int? quantity) {
    int totalPrdt = 0;

    if (quantity == null) {
      totalPrdt = _allProducts.length;
    } else {
      for (Product product in _allProducts) {
        if (product.quantity != null && product.quantity == quantity) {
          totalPrdt += 1;
        }
      }
    }

    return totalPrdt;
  }

  void filterProductsByQuantity(String productQfilter) {
    if (productQfilter == 'All Product') {
      _filteredProducts = List.from(_allProducts);
    } else if (productQfilter == 'Out Of Stack') {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 0;
      }).toList();
    } else if (productQfilter == 'Limited Stack') {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null && product.quantity == 1;
      }).toList();
    } else if (productQfilter == 'Other Stack') {
      _filteredProducts = _allProducts.where((product) {
        return product.quantity != null &&
            product.quantity != 1 &&
            product.quantity != 0;
      }).toList();
    } else {
      _filteredProducts = List.from(_allProducts);
    }
    notifyListeners();
  }

  void filterOrdersByPaymentStatus(String status) {
    if (status.isEmpty) {
      _filteredOrders = List.from(_allOrders);
    } else {
      _filteredOrders = _allOrders.where((order) {
        return (order.paymentStatus ?? '')
            .toLowerCase()
            .contains(status.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void _handleError(String message, dynamic error, bool showSnack) {
    _errorMessage = '$message: ${error.toString()}';
    if (kDebugMode) {
      print('❌ $message: $error');
    }
    if (showSnack) {
      SnackBarHelper.showErrorSnackBar(message);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<Order> get pendingPaymentVerification {
    return _allOrders
        .where((order) =>
            order.paymentMethod != 'cod' &&
            order.paymentStatus == 'pending' &&
            order.paymentProof?.imageUrl != null)
        .toList();
  }

  int get pendingVerificationCount {
    return pendingPaymentVerification.length;
  }

  Future<void> refreshAllData({bool showSnack = false}) async {
    await refreshScreenData('Dashboard', forceRefresh: true);
    if (showSnack) {
      SnackBarHelper.showSuccessSnackBar('Data refreshed successfully');
    }
  }
}
