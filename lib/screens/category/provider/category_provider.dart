import 'dart:io';
import 'dart:typed_data';
import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/widgets/camera_picker_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/http_services.dart';

class CategoryProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CategoryProvider(this._dataProvider);

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

  addCategory() async {
    try {
      setLoading(true);
      clearError();

      // Validate form
      if (!addCategoryFormKey.currentState!.validate()) {
        SnackBarHelper.showErrorSnackBar(
            "Please fill all required fields correctly");
        setLoading(false);
        return;
      }

      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar('Please select a category image');
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

      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text.trim(),
        'Image': 'no_image',
        'adminId': currentUserId, // CHANGED from createdBy to adminId
      };

      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      final response = await service.addItem(
        endpointUrl: 'categories',
        itemData: form,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Category added successfully! 🎉');
          await _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to add category: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Add category error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to add category. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  updateCategory() async {
    try {
      setLoading(true);
      clearError();

      if (categoryForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("No category selected for update");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canEditItem(categoryForUpdate!)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to edit this category');
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

      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text.trim(),
        'image': categoryForUpdate?.image ?? '',
        'adminId': currentUserId, // Use adminId consistently
      };

      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      final response = await service.updateItem(
        endpointUrl: 'categories',
        itemId: categoryForUpdate?.sId ?? '',
        itemData: form,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              'Category updated successfully! ✅');
          print('update category');
          await _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update category: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Update category error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to update category. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  submitCategory() {
    if (categoryForUpdate != null) {
      updateCategory();
    } else {
      addCategory();
    }
  }

  deleteCategory(Category category) async {
    try {
      setLoading(true);

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar("Authentication required");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canDeleteItem(category)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to delete this category');
        setLoading(false);
        return;
      }

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: Text("Delete Category"),
              content: Text(
                  "Are you sure you want to delete '${category.name}'? This action cannot be undone."),
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
        endpointUrl: 'categories',
        itemId: category.sId ?? '',
        body: {'adminId': currentUserId}, // Use adminId consistently
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar(
              "Category deleted successfully 🗑️");
          await _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to delete category: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Delete category error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to delete category. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  void pickImage(BuildContext context) async {
    try {
      showCameraPickerDialog(context, (XFile? image) async {
        if (image != null) {
          // Validate image size (max 5MB)
          final file = File(image.path);
          final fileSize = await file.length();
          if (fileSize > 5 * 1024 * 1024) {
            SnackBarHelper.showErrorSnackBar(
                "Image size must be less than 5MB");
            return;
          }

          selectedImage = file;
          imgXFile = image;
          notifyListeners();
          SnackBarHelper.showSuccessSnackBar("Image selected successfully");
        }
      });
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          "Failed to pick image. Please try again.");
    }
  }

  //? to create form data for sending image with body
  Future<FormData> createFormData({
    required XFile? imgXFile,
    required Map<String, dynamic> formData,
  }) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
    notifyListeners();
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
    clearError();
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    categoryNameCtrl.dispose();
    super.dispose();
  }
}
