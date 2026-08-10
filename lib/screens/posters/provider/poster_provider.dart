import 'dart:io';
import 'dart:typed_data';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/widgets/camera_picker_dialog.dart';
import 'package:flutter/material.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/poster.dart';
import '../../../services/admin_auth_service.dart';

class PosterProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  final addPosterFormKey = GlobalKey<FormState>();
  TextEditingController posterNameCtrl = TextEditingController();
  Poster? posterForUpdate;

  File? selectedImage;
  XFile? imgXFile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PosterProvider(this._dataProvider);

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

  addPoster() async {
    try {
      setLoading(true);
      clearError();

      if (!addPosterFormKey.currentState!.validate()) {
        SnackBarHelper.showErrorSnackBar(
            "Please fill all required fields correctly");
        setLoading(false);
        return;
      }

      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar("Please select a poster image");
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
        'posterName': posterNameCtrl.text.trim(),
        'image': 'no_data',
        'createdBy': currentUserId, // Add createdBy
      };

      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      final response = await service.addItem(
        endpointUrl: 'posters',
        itemData: form,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Poster added successfully! 🎉');
          await _dataProvider.getAllPosters();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to add poster: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Add poster error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to add poster. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  updatePoster() async {
    try {
      setLoading(true);
      clearError();

      if (posterForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("No poster selected for update");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canEditItem(posterForUpdate!)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to edit this poster');
        setLoading(false);
        return;
      }

      final currentUserId = _authService.getUserId();

      Map<String, dynamic> formDataMap = {
        'postername': posterNameCtrl.text.trim(),
        'image': 'no_data',
        'adminId': currentUserId, // Add adminId for ownership check
      };

      final FormData form = await createFormData(
        imgXFile: imgXFile,
        formData: formDataMap,
      );

      final response = await service.updateItem(
        endpointUrl: 'posters',
        itemId: posterForUpdate?.sId ?? '',
        itemData: form,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Poster updated successfully! ✅');
          await _dataProvider.getAllPosters();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update poster: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Update poster error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to update poster. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  submitPoster() {
    if (posterForUpdate != null) {
      updatePoster();
    } else {
      addPoster();
    }
  }

  deletePoster(Poster poster) async {
    try {
      setLoading(true);

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar("Authentication required");
        setLoading(false);
        return;
      }

      // Check permission
      if (!_authService.canDeleteItem(poster)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to delete this poster');
        setLoading(false);
        return;
      }

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: Text("Delete Poster"),
              content: Text(
                  "Are you sure you want to delete '${poster.posterName}'? This action cannot be undone."),
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
        endpointUrl: 'posters',
        itemId: poster.sId ?? '',
        body: {'adminId': currentUserId}, // Add adminId for ownership check
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar("Poster deleted successfully 🗑️");
          await _dataProvider.getAllPosters();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to delete poster: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Delete poster error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to delete poster. Please try again.");
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

  setDataForUpdatePoster(Poster? poster) {
    if (poster != null) {
      clearFields();
      posterForUpdate = poster;
      posterNameCtrl.text = poster.posterName ?? '';
    } else {
      clearFields();
    }
    notifyListeners();
  }

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

  clearFields() {
    posterNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    posterForUpdate = null;
    clearError();
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }

  @override
  void dispose() {
    posterNameCtrl.dispose();
    super.dispose();
  }
}
