import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/variant_type.dart';
import '../../../services/admin_auth_service.dart';
import '../../../services/http_services.dart';
import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:admin_panal_start/utility/error_utils.dart';

class VariantTypeProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  final addVariantTypeFormKey = GlobalKey<FormState>();
  TextEditingController variantTypeNameCtrl = TextEditingController();
  TextEditingController variantTypeTypeCtrl = TextEditingController();
  VariantType? variantTypeForUpdate;

  VariantTypeProvider(this._dataProvider);

  addVariantType() async {
    try {
      final currentUserId = _authService.getUserId();

      Map<String, dynamic> variantType = {
        'name': variantTypeNameCtrl.text,
        'type': variantTypeTypeCtrl.text,
        'createdBy': currentUserId, // Add createdBy
      };

      final response = await service.addItem(
        endpointUrl: 'variantTypes',
        itemData: variantType,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar('Variant type added successfully');
          _dataProvider.getAllVariantType();
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

  updateVariantType() async {
    try {
      // Check permission
      if (!_authService.canEditItem(variantTypeForUpdate)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to edit this variant type');
        return;
      }

      Map<String, dynamic> variantType = {
        'name': variantTypeNameCtrl.text,
        'type': variantTypeTypeCtrl.text,
      };

      final response = await service.updateItem(
        endpointUrl: 'variantTypes',
        itemId: variantTypeForUpdate?.sId ?? '',
        itemData: variantType,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(
              'Variant type updated successfully');
          _dataProvider.getAllVariantType();
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

  submitVariantType() {
    if (variantTypeForUpdate != null) {
      updateVariantType();
    } else {
      addVariantType();
    }
  }

  deleteVariantType(VariantType variantType) async {
    try {
      // Check permission
      if (!_authService.canDeleteItem(variantType)) {
        SnackBarHelper.showErrorSnackBar(
            'You do not have permission to delete this variant type');
        return;
      }

      Response response = await service.deleteItem(
        endpointUrl: 'variantTypes',
        itemId: variantType.sId ?? '',
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar(
              "Variant type deleted successfully");
          _dataProvider.getAllVariantType();
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

  setDataForUpdateVariantType(VariantType? variantType) {
    if (variantType != null) {
      variantTypeForUpdate = variantType;
      variantTypeNameCtrl.text = variantType.name ?? '';
      variantTypeTypeCtrl.text = variantType.type ?? '';
    } else {
      clearFields();
    }
  }

  clearFields() {
    variantTypeNameCtrl.clear();
    variantTypeTypeCtrl.clear();
    variantTypeForUpdate = null;
  }

  updateUI() {
    notifyListeners();
  }
}
