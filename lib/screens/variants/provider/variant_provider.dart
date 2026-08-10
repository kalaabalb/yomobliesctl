import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';
import '../../../models/variant_type.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/http_services.dart';
import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/utility/error_utils.dart';

class VariantProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  final addVariantFormKey = GlobalKey<FormState>();
  TextEditingController variantNameCtrl = TextEditingController();
  VariantType? selectedVariantType;
  Variant? variantForUpdate;

  VariantProvider(this._dataProvider);

  addVariant() async {
    try {
      final currentUserId = _authService.getUserId();

      Map<String, dynamic> variant = {
        'name': variantNameCtrl.text,
        'variantTypeId': selectedVariantType?.sId,
        'createdBy': currentUserId, // Add createdBy
      };

      final response = await service.addItem(
        endpointUrl: 'variants',
        itemData: variant,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Variant added successfully');
          _dataProvider.getAllVariant();
        } else {
          SnackBarHelper.showOperationErrorSnackBar('add', apiResponse.message);
        }
      } else {
        SnackBarHelper.showOperationErrorSnackBar('add', response.statusText);
      }
    } catch (e) {
      SnackBarHelper.showOperationErrorSnackBar('add', e);
      rethrow;
    }
  }

  updateVariant() async {
    try {
      // Check permission
      if (!_authService.canEditItem(variantForUpdate)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to edit this variant');
        return;
      }

      Map<String, dynamic> variant = {
        'name': variantNameCtrl.text,
        'variantTypeId': selectedVariantType?.sId,
      };

      final response = await service.updateItem(
        endpointUrl: 'variants',
        itemId: variantForUpdate?.sId ?? '',
        itemData: variant,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Variant updated successfully');
          _dataProvider.getAllVariant();
        } else {
          SnackBarHelper.showOperationErrorSnackBar(
              'update', apiResponse.message);
        }
      } else {
        SnackBarHelper.showOperationErrorSnackBar(
            'update', response.statusText);
      }
    } catch (e) {
      SnackBarHelper.showOperationErrorSnackBar('update', e);
      rethrow;
    }
  }

  submitVariant() {
    if (variantForUpdate != null) {
      updateVariant();
    } else {
      addVariant();
    }
  }

  deleteVariant(Variant variant) async {
    try {
      // Check permission
      if (!_authService.canDeleteItem(variant)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to delete this variant');
        return;
      }

      Response response = await service.deleteItem(
        endpointUrl: 'variants',
        itemId: variant.sId ?? '',
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar("Variant deleted successfully");
          _dataProvider.getAllVariant();
        } else {
          SnackBarHelper.showOperationErrorSnackBar(
              'delete', apiResponse.message);
        }
      } else {
        SnackBarHelper.showOperationErrorSnackBar(
            'delete', response.statusText);
      }
    } catch (e) {
      SnackBarHelper.showOperationErrorSnackBar('delete', e);
      rethrow;
    }
  }

  setDataForUpdateVariant(Variant? variant) {
    if (variant != null) {
      variantForUpdate = variant;
      variantNameCtrl.text = variant.name ?? '';
      selectedVariantType = _dataProvider.variantTypes.firstWhereOrNull(
        (element) => element.sId == variant.variantTypeId?.sId,
      );
    } else {
      clearFields();
    }
  }

  clearFields() {
    variantNameCtrl.clear();
    selectedVariantType = null;
    variantForUpdate = null;
  }

  updateUI() {
    notifyListeners();
  }
}
