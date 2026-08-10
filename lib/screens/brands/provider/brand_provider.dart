import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/http_services.dart';
import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/utility/error_utils.dart';

class BrandProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  final addBrandFormKey = GlobalKey<FormState>();
  TextEditingController brandNameCtrl = TextEditingController();
  SubCategory? selectedSubCategory;
  Brand? brandForUpdate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BrandProvider(this._dataProvider);

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

  addBrand() async {
    try {
      setLoading(true);
      clearError();

      if (!addBrandFormKey.currentState!.validate()) {
        SnackBarHelper.showErrorSnackBar(
            "Please fill all required fields correctly");
        setLoading(false);
        return;
      }

      if (selectedSubCategory == null) {
        SnackBarHelper.showErrorSnackBar("Please select a subcategory");
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

      Map<String, dynamic> brand = {
        'name': brandNameCtrl.text.trim(),
        'subcategoryId': selectedSubCategory?.sId,
        'adminId': currentUserId, // Use adminId consistently
      };

      final response = await service.addItem(
        endpointUrl: 'brands',
        itemData: brand,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Brand added successfully! 🎉');
          await _dataProvider.getAllBrands();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to add brand: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Add brand error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to add brand. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  updateBrand() async {
    try {
      setLoading(true);
      clearError();

      if (brandForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("No brand selected for update");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canEditItem(brandForUpdate!)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to edit this brand');
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

      Map<String, dynamic> brand = {
        'name': brandNameCtrl.text.trim(),
        'subcategoryId': selectedSubCategory?.sId,
        'adminId': currentUserId, // Use adminId consistently
      };

      final response = await service.updateItem(
        endpointUrl: 'brands',
        itemId: brandForUpdate?.sId ?? '',
        itemData: brand,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Brand updated successfully! ✅');
          await _dataProvider.getAllBrands();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update brand: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Update brand error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to update brand. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  submiteBrand() {
    if (brandForUpdate != null) {
      updateBrand();
    } else {
      addBrand();
    }
  }

  deleteBrand(Brand brand) async {
    try {
      setLoading(true);

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar("Authentication required");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canDeleteItem(brand)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to delete this brand');
        setLoading(false);
        return;
      }

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: Text("Delete Brand"),
              content: Text(
                  "Are you sure you want to delete '${brand.name}'? This action cannot be undone."),
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
        endpointUrl: 'brands',
        itemId: brand.sId ?? '',
        body: {'adminId': currentUserId}, // Use adminId consistently
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar("Brand deleted successfully 🗑️");
          await _dataProvider.getAllBrands();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to delete brand: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Delete brand error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to delete brand. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  setDataForUpdateBrand(Brand? brand) async {
    if (brand != null) {
      brandForUpdate = brand;
      brandNameCtrl.text = brand.name ?? '';

      // Find and set the subcategory with a small delay to ensure data is loaded
      await Future.delayed(Duration(milliseconds: 100));

      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
        (element) => element.sId == brand.subcategoryId?.sId,
      );
    } else {
      clearFields();
    }
    notifyListeners();
  }

  clearFields() {
    brandNameCtrl.clear();
    selectedSubCategory = null;
    brandForUpdate = null;
    clearError();
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    brandNameCtrl.dispose();
    super.dispose();
  }
}
