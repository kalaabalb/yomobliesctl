import 'dart:io';
import 'dart:typed_data';
import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/widgets/camera_picker_dialog.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/brand.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../services/http_services.dart';
import '../../../models/product.dart';
import 'package:admin_panal_start/models/api_response.dart';

class DashBoardProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final addProductFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productDescCtrl = TextEditingController();
  TextEditingController productQntCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productOffPriceCtrl = TextEditingController();

  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  Brand? selectedBrand;
  VariantType? selectedVariantType;
  List<String> selectedVariants = [];

  Product? productForUpdate;
  File? selectedMainImage,
      selectedSecondImage,
      selectedThirdImage,
      selectedFourthImage,
      selectedFifthImage;
  XFile? mainImgXFile,
      secondImgXFile,
      thirdImgXFile,
      fourthImgXFile,
      fifthImgXFile;

  List<SubCategory> subCategoriesByCategory = [];
  List<Brand> brandsBySubCategory = [];
  List<String> variantsByVariantType = [];

  DashBoardProvider(this._dataProvider);

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
  }

  addProduct() async {
    try {
      setLoading(true);
      clearError();

      if (selectedMainImage == null) {
        SnackBarHelper.showErrorSnackBar("Please select a main product image");
        setLoading(false);
        return;
      }

      if (!addProductFormKey.currentState!.validate()) {
        SnackBarHelper.showErrorSnackBar(
            "Please fill all required fields correctly");
        setLoading(false);
        return;
      }

      final authService = Get.find<AdminAuthService>();
      final currentUserId = authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar(
            "Authentication required. Please login again.");
        setLoading(false);
        return;
      }

      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text.trim(),
        'description': productDescCtrl.text.trim(),
        'quantity': productQntCtrl.text,
        'price': productPriceCtrl.text,
        'offerPrice':
            productOffPriceCtrl.text.isEmpty ? null : productOffPriceCtrl.text,
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'proBrandId': selectedBrand?.sId,
        'proVariantTypeId': selectedVariantType?.sId,
        'proVariantId': selectedVariants,
        'adminId': currentUserId, // Use adminId consistently
      };

      formDataMap.removeWhere((key, value) => value == null || value == '');

      final FormData form = await createFormDataForMultipleImage(
        imgXFiles: [
          {'image1': mainImgXFile},
          {'image2': secondImgXFile},
          {'image3': thirdImgXFile},
          {'image4': fourthImgXFile},
          {'image5': fifthImgXFile},
        ],
        formData: formDataMap,
      );

      final response = await service.addItem(
        endpointUrl: 'products',
        itemData: form,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Product added successfully! 🎉');
          await _dataProvider.getAllProduct();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to add product: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Add product error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to add product. Please check your connection and try again.");
    } finally {
      setLoading(false);
    }
  }

  updateProduct() async {
    try {
      setLoading(true);
      clearError();

      if (productForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("No product selected for update");
        setLoading(false);
        return;
      }

      final authService = Get.find<AdminAuthService>();
      final currentUserId = authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar(
            "Authentication required. Please login again.");
        setLoading(false);
        return;
      }

      Map<String, dynamic> formDataMap = {
        'name': productNameCtrl.text.trim(),
        'description': productDescCtrl.text.trim(),
        'quantity': productQntCtrl.text,
        'price': productPriceCtrl.text,
        'offerPrice':
            productOffPriceCtrl.text.isEmpty ? null : productOffPriceCtrl.text,
        'proCategoryId': selectedCategory?.sId ?? '',
        'proSubCategoryId': selectedSubCategory?.sId ?? '',
        'proBrandId': selectedBrand?.sId,
        'proVariantTypeId': selectedVariantType?.sId,
        'proVariantId': selectedVariants,
        'adminId': currentUserId, // Use adminId consistently
      };

      formDataMap.removeWhere((key, value) => value == null || value == '');

      final FormData form = await createFormDataForMultipleImage(
        imgXFiles: [
          {'image1': mainImgXFile},
          {'image2': secondImgXFile},
          {'image3': thirdImgXFile},
          {'image4': fourthImgXFile},
          {'image5': fifthImgXFile},
        ],
        formData: formDataMap,
      );

      final response = await service.updateItem(
        endpointUrl: 'products',
        itemData: form,
        itemId: '${productForUpdate?.sId}',
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Product updated successfully! ✅');
          await _dataProvider.getAllProduct();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update product: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Update product error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to update product. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  submitProduct() {
    if (productForUpdate != null) {
      updateProduct();
    } else {
      addProduct();
    }
  }

  deleteProduct(Product product) async {
    try {
      setLoading(true);
      clearError();

      final authService = Get.find<AdminAuthService>();
      final currentUserId = authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar("Authentication required");
        setLoading(false);
        return;
      }

      bool confirmDelete = await showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: Text("Delete Product"),
              content: Text(
                  "Are you sure you want to delete '${product.name}'? This action cannot be undone."),
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
        endpointUrl: 'products',
        itemId: product.sId ?? '',
        body: {'adminId': currentUserId}, // Use adminId consistently
      );

      if (response.isOk) {
        final responseBody = response.body;

        // Check if response indicates success
        if (responseBody is Map && responseBody['success'] == true) {
          SnackBarHelper.showSuccessSnackBar("Product deleted successfully");
          await _dataProvider.getAllProduct();
        } else {
          final errorMessage =
              responseBody?['message'] ?? "Failed to delete product";
          SnackBarHelper.showErrorSnackBar(errorMessage);
        }
      } else {
        // Don't logout for non-401 errors
        if (response.statusCode != 401) {
          final errorMessage = response.body?['message'] ??
              response.statusText ??
              "Failed to delete product";
          SnackBarHelper.showErrorSnackBar(errorMessage);
        }
      }
    } catch (e) {
      print("Delete product error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to delete product. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  void pickImage(
      {required int imageCardNumber, required BuildContext context}) async {
    try {
      showCameraPickerDialog(context, (XFile? image) async {
        if (image != null) {
          final file = File(image.path);
          final fileSize = await file.length();
          if (fileSize > 5 * 1024 * 1024) {
            SnackBarHelper.showErrorSnackBar(
                "Image size must be less than 5MB");
            return;
          }

          switch (imageCardNumber) {
            case 1:
              selectedMainImage = file;
              mainImgXFile = image;
              break;
            case 2:
              selectedSecondImage = file;
              secondImgXFile = image;
              break;
            case 3:
              selectedThirdImage = file;
              thirdImgXFile = image;
              break;
            case 4:
              selectedFourthImage = file;
              fourthImgXFile = image;
              break;
            case 5:
              selectedFifthImage = file;
              fifthImgXFile = image;
              break;
          }
          notifyListeners();
          SnackBarHelper.showSuccessSnackBar("Image selected successfully");
        }
      });
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          "Failed to pick image. Please try again.");
    }
  }

  Future<FormData> createFormDataForMultipleImage({
    required List<Map<String, XFile?>>? imgXFiles,
    required Map<String, dynamic> formData,
  }) async {
    int imageCount = 0;

    if (imgXFiles != null) {
      for (int i = 0; i < imgXFiles.length; i++) {
        String imageKey = 'image${i + 1}';
        XFile? imgXFile = imgXFiles[i][imageKey];

        if (imgXFile != null) {
          imageCount++;

          if (kIsWeb) {
            String fileName = imgXFile.name;
            Uint8List byteImg = await imgXFile.readAsBytes();
            formData[imageKey] = MultipartFile(
              byteImg,
              filename: fileName,
            );
          } else {
            String filePath = imgXFile.path;
            String fileName = filePath.split('/').last;
            File file = File(filePath);
            if (await file.exists()) {
              formData[imageKey] = await MultipartFile(
                filePath,
                filename: fileName,
              );
            }
          }
        }
      }
    }

    final FormData form = FormData(formData);
    return form;
  }

  void filterSubcategory(Category? category) {
    selectedBrand = null;
    selectedCategory = category;
    selectedSubCategory = null;
    subCategoriesByCategory.clear();

    if (category != null) {
      final newList = _dataProvider.subCategories
          .where((subcategory) => subcategory.categoryId?.sId == category.sId)
          .toList();
      subCategoriesByCategory = newList;
    } else {
      subCategoriesByCategory = [];
    }

    notifyListeners();
  }

  void filterBrand(SubCategory? subCategory) {
    selectedBrand = null;
    selectedSubCategory = subCategory;
    brandsBySubCategory.clear();

    if (subCategory != null) {
      final newList = _dataProvider.brands
          .where((brand) => brand.subcategoryId?.sId == subCategory.sId)
          .toList();
      brandsBySubCategory = newList;
    } else {
      brandsBySubCategory = [];
    }

    notifyListeners();
  }

  void filterVariant(VariantType? variantType) {
    selectedVariants = [];
    selectedVariantType = variantType;
    variantsByVariantType.clear();

    if (variantType != null) {
      final newList = _dataProvider.variants
          .where((variant) => variant.variantTypeId?.sId == variantType.sId)
          .toList();
      variantsByVariantType =
          newList.map((variant) => variant.name ?? '').toList();
    } else {
      variantsByVariantType = [];
    }

    notifyListeners();
  }

  setDataForUpdateProduct(Product? product) async {
    if (product != null) {
      productForUpdate = product;

      productNameCtrl.text = product.name ?? '';
      productDescCtrl.text = product.description ?? '';
      productPriceCtrl.text = product.price?.toString() ?? '';
      productOffPriceCtrl.text = product.offerPrice?.toString() ?? '';
      productQntCtrl.text = product.quantity?.toString() ?? '';

      // Set category and filter subcategories
      selectedCategory = _dataProvider.categories.firstWhereOrNull(
        (element) => element.sId == product.proCategoryId?.sId,
      );

      if (selectedCategory != null) {
        // Wait for data to load before filtering
        await Future.delayed(Duration(milliseconds: 100));
        filterSubcategory(selectedCategory);
      }

      // Set subcategory and filter brands
      selectedSubCategory = _dataProvider.subCategories.firstWhereOrNull(
        (element) => element.sId == product.proSubCategoryId?.sId,
      );

      if (selectedSubCategory != null) {
        await Future.delayed(Duration(milliseconds: 100));
        filterBrand(selectedSubCategory);
      }

      // Set brand
      selectedBrand = _dataProvider.brands.firstWhereOrNull(
        (element) => element.sId == product.proBrandId?.sId,
      );

      // Set variant type and filter variants
      selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull(
        (element) => element.sId == product.proVariantTypeId?.sId,
      );

      if (selectedVariantType != null) {
        await Future.delayed(Duration(milliseconds: 100));
        filterVariant(selectedVariantType);
      }

      selectedVariants = product.proVariantId ?? [];

      // Force UI update
      scheduleNotifyListeners();
    } else {
      _resetFieldsForUpdate();
    }
  }

  void _resetFieldsForUpdate() {
    productNameCtrl.clear();
    productDescCtrl.clear();
    productPriceCtrl.clear();
    productOffPriceCtrl.clear();
    productQntCtrl.clear();

    selectedMainImage = null;
    selectedSecondImage = null;
    selectedThirdImage = null;
    selectedFourthImage = null;
    selectedFifthImage = null;

    mainImgXFile = null;
    secondImgXFile = null;
    thirdImgXFile = null;
    fourthImgXFile = null;
    fifthImgXFile = null;

    selectedCategory = null;
    selectedSubCategory = null;
    selectedBrand = null;
    selectedVariantType = null;
    selectedVariants = [];

    productForUpdate = null;

    subCategoriesByCategory = [];
    brandsBySubCategory = [];
    variantsByVariantType = [];

    clearError();
  }

  void scheduleNotifyListeners() {
    Future.microtask(() {
      notifyListeners();
    });
  }

  clearFields() {
    _resetFieldsForUpdate();
    scheduleNotifyListeners();
  }

  updateUI() {
    scheduleNotifyListeners();
  }

  @override
  void dispose() {
    productNameCtrl.dispose();
    productDescCtrl.dispose();
    productPriceCtrl.dispose();
    productOffPriceCtrl.dispose();
    productQntCtrl.dispose();
    super.dispose();
  }
}
