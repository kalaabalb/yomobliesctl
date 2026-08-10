import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../models/sub_category.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/http_services.dart';
import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/utility/error_utils.dart';

class SubCategoryProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  final addSubCategoryFormKey = GlobalKey<FormState>();
  TextEditingController subCategoryNameCtrl = TextEditingController();
  Category? selectedCategory;
  SubCategory? subCategoryForUpdate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SubCategoryProvider(this._dataProvider);

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

  addSubCategory() async {
    try {
      setLoading(true);
      clearError();

      if (!addSubCategoryFormKey.currentState!.validate()) {
        SnackBarHelper.showErrorSnackBar(
            "Please fill all required fields correctly");
        setLoading(false);
        return;
      }

      if (selectedCategory == null) {
        SnackBarHelper.showErrorSnackBar("Please select a category");
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

      Map<String, dynamic> subCategory = {
        'name': subCategoryNameCtrl.text.trim(),
        'categoryId': selectedCategory?.sId,
        'adminId': currentUserId, // Use adminId consistently
      };

      final response = await service.addItem(
        endpointUrl: 'subCategories',
        itemData: subCategory,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              'Sub Category added successfully! 🎉');
          await _dataProvider.getAllSubCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to add sub category: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Add sub category error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to add sub category. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  updateSubCategory() async {
    try {
      setLoading(true);
      clearError();

      if (subCategoryForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("No sub category selected for update");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canEditItem(subCategoryForUpdate!)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to edit this sub category');
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

      Map<String, dynamic> subCategory = {
        'name': subCategoryNameCtrl.text.trim(),
        'categoryId': selectedCategory?.sId,
        'adminId': currentUserId, // Use adminId consistently
      };

      final response = await service.updateItem(
        endpointUrl: 'subCategories',
        itemId: subCategoryForUpdate?.sId ?? '',
        itemData: subCategory,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              'Sub Category updated successfully! ✅');
          await _dataProvider.getAllSubCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update sub category: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Update sub category error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to update sub category. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  submitSubCategory() {
    if (subCategoryForUpdate != null) {
      updateSubCategory();
    } else {
      addSubCategory();
    }
  }

  deleteSubCategory(SubCategory subCategory) async {
    try {
      setLoading(true);

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar("Authentication required");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canDeleteItem(subCategory)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to delete this sub category');
        setLoading(false);
        return;
      }

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: Text("Delete Sub Category"),
              content: Text(
                  "Are you sure you want to delete '${subCategory.name}'? This action cannot be undone."),
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
        endpointUrl: 'subCategories',
        itemId: subCategory.sId ?? '',
        body: {'adminId': currentUserId}, // Use adminId consistently
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar(
              "Sub Category deleted successfully 🗑️");
          await _dataProvider.getAllSubCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to delete sub category: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Delete sub category error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to delete sub category. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  setDataForUpdateSubCategory(SubCategory? subCategory) async {
    if (subCategory != null) {
      subCategoryForUpdate = subCategory;
      subCategoryNameCtrl.text = subCategory.name ?? '';

      // Find and set the category with a small delay to ensure data is loaded
      await Future.delayed(Duration(milliseconds: 100));

      selectedCategory = _dataProvider.categories.firstWhereOrNull(
        (element) => element.sId == subCategory.categoryId?.sId,
      );
    } else {
      clearFields();
    }
    notifyListeners();
  }

  clearFields() {
    subCategoryNameCtrl.clear();
    selectedCategory = null;
    subCategoryForUpdate = null;
    clearError();
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    subCategoryNameCtrl.dispose();
    super.dispose();
  }
}
