import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import '../../../models/order.dart';
import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/data/data_provider.dart';

class OrderProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();
  final DataProvider _dataProvider;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  final orderFormKey = GlobalKey<FormState>();
  TextEditingController trackingUrlCtrl = TextEditingController();
  String selectedOrderStatus = 'pending';
  Order? orderForUpdate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OrderProvider(this._dataProvider);

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

  updateOrder() async {
    try {
      setLoading(true);
      clearError();

      if (orderForUpdate == null) {
        SnackBarHelper.showErrorSnackBar("No order selected for update");
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

      Map<String, dynamic> order = {
        'trackingUrl': trackingUrlCtrl.text.trim(),
        'orderStatus': selectedOrderStatus,
        'adminId': currentUserId // Add adminId for ownership check
      };

      final response = await service.updateItem(
        endpointUrl: 'orders',
        itemId: orderForUpdate?.sId ?? '',
        itemData: order,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar('Order updated successfully! ✅');
          await _dataProvider.getAllOrders();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to update order: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Update order error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to update order. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  verifyPayment(Order order, bool verified) async {
    try {
      setLoading(true);
      clearError();

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar(
            "Authentication required. Please login again.");
        setLoading(false);
        return;
      }

      final response = await service.updateItem(
        endpointUrl: 'orders',
        itemId: '${order.sId}/verify-payment',
        itemData: {
          'verified': verified,
          'adminId': currentUserId // Add adminId for ownership check
        },
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar(
              'Payment verification updated successfully! ✅');
          await _dataProvider.getAllOrders();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to verify payment: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Verify payment error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to verify payment. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  Future<List<Order>> getOrdersByPaymentStatus(String status) async {
    try {
      final response = await service.getItems(
        endpointUrl: 'orders/payment-status/$status',
      );

      if (response.isOk) {
        ApiResponse<List<Order>> apiResponse = ApiResponse.fromJson(
          response.body,
          (json) => (json as List).map((item) => Order.fromJson(item)).toList(),
        );
        return apiResponse.data ?? [];
      }
      return [];
    } catch (e) {
      SnackBarHelper.showErrorSnackBar("Failed to fetch orders: $e");
      return [];
    }
  }

  deleteOrder(Order order) async {
    try {
      setLoading(true);

      final currentUserId = _authService.getUserId();

      if (currentUserId == null) {
        SnackBarHelper.showErrorSnackBar("Authentication required");
        setLoading(false);
        return;
      }

      // Show confirmation dialog
      bool confirmDelete = await showDialog(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: Text("Delete Order"),
              content: Text(
                  "Are you sure you want to delete order #${_shortOrderId(order.sId)}? This action cannot be undone."),
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
        endpointUrl: 'orders',
        itemId: order.sId ?? '',
        body: {'adminId': currentUserId}, // Add adminId for ownership check
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success) {
          SnackBarHelper.showSuccessSnackBar("Order deleted successfully 🗑️");
          await _dataProvider.getAllOrders();
        } else {
          SnackBarHelper.showErrorSnackBar(
            "Failed to delete order: ${apiResponse.message}",
          );
        }
      } else {
        String errorMessage = response.body?["message"] ??
            response.statusText ??
            "Unknown error occurred";
        SnackBarHelper.showErrorSnackBar("Error: $errorMessage");
      }
    } catch (e) {
      print("Delete order error: $e");
      SnackBarHelper.showErrorSnackBar(
          "Failed to delete order. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  updateUI() {
    notifyListeners();
  }

  String _shortOrderId(String? orderId) {
    if (orderId == null || orderId.isEmpty) return 'N/A';
    return orderId.length > 6 ? orderId.substring(orderId.length - 6) : orderId;
  }

  @override
  void dispose() {
    trackingUrlCtrl.dispose();
    super.dispose();
  }
}
