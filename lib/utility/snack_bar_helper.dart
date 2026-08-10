import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'error_utils.dart';

class SnackBarHelper {
  static void showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

  static void showErrorSnackBar(String message, [dynamic error]) {
    final userMessage =
        error != null ? ErrorUtils.getHumanReadableError(error) : message;

    Get.snackbar(
      'Error',
      userMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 4),
    );
  }

  static void showOperationErrorSnackBar(String operation, dynamic error) {
    final userMessage = ErrorUtils.getOperationErrorMessage(operation);

    Get.snackbar(
      'Error',
      userMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 4),
    );
  }

  static void showInfoSnackBar(String message) {
    Get.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

  static void showWarningSnackBar(String message) {
    Get.snackbar(
      'Warning',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 4),
    );
  }
}
