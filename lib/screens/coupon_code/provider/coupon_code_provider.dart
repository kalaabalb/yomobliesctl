import 'package:flutter/material.dart';
import '../../../models/coupon.dart';
import '../../../models/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/http_services.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/models/api_response.dart';

class CouponCodeProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  Coupon? couponForUpdate;

  final addCouponFormKey = GlobalKey<FormState>();
  TextEditingController couponCodeCtrl = TextEditingController();
  TextEditingController discountAmountCtrl = TextEditingController();
  TextEditingController minimumPurchaseAmountCtrl = TextEditingController();
  TextEditingController endDateCtrl = TextEditingController();
  String selectedDiscountType = 'fixed';
  String selectedCouponStatus = 'active';
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Product? selectedProduct;

  // Filtered lists for cascade dropdowns
  List<SubCategory> filteredSubCategories = [];
  List<Product> filteredProducts = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CouponCodeProvider(this._dataProvider);

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear errors
  void clearError() {
    _errorMessage = null;
  }

  // Cascade filtering methods
  void filterSubCategoriesByCategory(Category? category) {
    selectedSubCategory = null;
    selectedProduct = null;
    filteredSubCategories.clear();
    filteredProducts.clear();

    if (category != null) {
      filteredSubCategories = _dataProvider.subCategories
          .where((subCategory) => subCategory.categoryId?.sId == category.sId)
          .toList();
    }
    notifyListeners();
  }

  void filterProductsBySubCategory(SubCategory? subCategory) {
    selectedProduct = null;
    filteredProducts.clear();

    if (subCategory != null) {
      filteredProducts = _dataProvider.products
          .where((product) => product.proSubCategoryId?.sId == subCategory.sId)
          .toList();
    }
    notifyListeners();
  }

  addCoupon() async {
    try {
      setLoading(true);
      clearError();

      if (!addCouponFormKey.currentState!.validate()) {
        SnackBarHelper.showErrorSnackBar(
            "Please fill all required fields correctly");
        setLoading(false);
        return;
      }

      if (endDateCtrl.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar("Please select an end date");
        setLoading(false);
        return;
      }

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar(
            "Authentication required. Please login again.");
        setLoading(false);
        return;
      }

      Map<String, dynamic> coupon = {
        'couponCode': couponCodeCtrl.text.trim(),
        'discountType': selectedDiscountType,
        'discountAmount': discountAmountCtrl.text.isEmpty
            ? 0
            : double.parse(discountAmountCtrl.text),
        'minimumPurchaseAmount': minimumPurchaseAmountCtrl.text.isEmpty
            ? 0
            : double.parse(minimumPurchaseAmountCtrl.text),
        'endDate': endDateCtrl.text,
        'status': selectedCouponStatus,
        'applicableCategory': selectedCategory?.sId,
        'applicableSubCategory': selectedSubCategory?.sId,
        'applicableProduct': selectedProduct?.sId,
        'adminId': currentUserId, // Use adminId consistently
      };

      final response = await service.addItem(
        endpointUrl: 'couponCodes',
        itemData: coupon,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Coupon added successfully! 🎉');
          await _dataProvider.getAllCoupons();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to add coupon: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Add coupon error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to add coupon. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  updateCoupon() async {
    try {
      setLoading(true);
      clearError();

      if (couponForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("No coupon selected for update");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canEditItem(couponForUpdate!)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to edit this coupon');
        setLoading(false);
        return;
      }

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar(
            "Authentication required. Please login again.");
        setLoading(false);
        return;
      }

      Map<String, dynamic> coupon = {
        'couponCode': couponCodeCtrl.text.trim(),
        'discountType': selectedDiscountType,
        'discountAmount': discountAmountCtrl.text.isEmpty
            ? 0
            : double.parse(discountAmountCtrl.text),
        'minimumPurchaseAmount': minimumPurchaseAmountCtrl.text.isEmpty
            ? 0
            : double.parse(minimumPurchaseAmountCtrl.text),
        'endDate': endDateCtrl.text,
        'status': selectedCouponStatus,
        'applicableCategory': selectedCategory?.sId,
        'applicableSubCategory': selectedSubCategory?.sId,
        'applicableProduct': selectedProduct?.sId,
        'adminId': currentUserId, // Use adminId consistently
      };

      final response = await service.updateItem(
        endpointUrl: 'couponCodes',
        itemId: couponForUpdate?.sId ?? '',
        itemData: coupon,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Coupon updated successfully! ✅');
          await _dataProvider.getAllCoupons();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update coupon: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Update coupon error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to update coupon. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  submitCoupon() {
    if (couponForUpdate != null) {
      updateCoupon();
    } else {
      addCoupon();
    }
  }

  deleteCoupon(Coupon coupon) async {
    try {
      setLoading(true);

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar("Authentication required");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canDeleteItem(coupon)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to delete this coupon');
        setLoading(false);
        return;
      }

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: Text("Delete Coupon"),
              content: Text(
                  "Are you sure you want to delete '${coupon.couponCode}'? This action cannot be undone."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmDelete) {
        setLoading(false);
        return;
      }

      Response response = await service.deleteItem(
        endpointUrl: 'couponCodes',
        itemId: coupon.sId ?? '',
        body: {'adminId': currentUserId}, // Use adminId consistently
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar("Coupon deleted successfully 🗑️");
          await _dataProvider.getAllCoupons();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to delete coupon: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Delete coupon error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to delete coupon. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  setDataForUpdateCoupon(Coupon? coupon) async {
    if (coupon != null) {
      couponForUpdate = coupon;
      couponCodeCtrl.text = coupon.couponCode ?? '';
      selectedDiscountType = coupon.discountType ?? 'fixed';
      discountAmountCtrl.text = '${coupon.discountAmount ?? ''}';
      minimumPurchaseAmountCtrl.text = '${coupon.minimumPurchaseAmount ?? ''}';
      endDateCtrl.text = '${coupon.endDate ?? ''}';
      selectedCouponStatus = coupon.status ?? 'active';

      // Set category and filter subcategories
      selectedCategory = _dataProvider.categories.firstWhereOrNull(
        (element) => element.sId == coupon.applicableCategory?.sId,
      );

      if (selectedCategory != null) {
        await Future.delayed(Duration(milliseconds: 100));
        filterSubCategoriesByCategory(selectedCategory);
      }

      // Set subcategory and filter products
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
        (element) => element.sId == coupon.applicableSubCategory?.sId,
      );

      if (selectedSubCategory != null) {
        await Future.delayed(Duration(milliseconds: 100));
        filterProductsBySubCategory(selectedSubCategory);
      }

      // Set product
      selectedProduct = _dataProvider.products.firstWhereOrNull(
        (element) => element.sId == coupon.applicableProduct?.sId,
      );
    } else {
      clearFields();
    }
    notifyListeners();
  }

  clearFields() {
    couponForUpdate = null;
    selectedCategory = null;
    selectedSubCategory = null;
    selectedProduct = null;
    filteredSubCategories.clear();
    filteredProducts.clear();

    couponCodeCtrl.clear();
    discountAmountCtrl.clear();
    minimumPurchaseAmountCtrl.clear();
    endDateCtrl.clear();

    selectedDiscountType = 'fixed';
    selectedCouponStatus = 'active';

    clearError();
    notifyListeners();
  }

  updateUi() {
    notifyListeners();
  }

  @override
  void dispose() {
    couponCodeCtrl.dispose();
    discountAmountCtrl.dispose();
    minimumPurchaseAmountCtrl.dispose();
    endDateCtrl.dispose();
    super.dispose();
  }
}
