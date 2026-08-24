import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../models/rating.dart';
import '../../../services/http_services.dart';
import '../../../utility/snack_bar_helper.dart';

class RatingProvider extends ChangeNotifier {
  final HttpService service = Get.find<HttpService>();

  RatingProvider();

  // Get ratings for a product
  Future<List<Rating>> getProductRatings(String productId) async {
    try {
      final response = await service.getItems(
        endpointUrl: 'ratings/product/$productId',
      );

      debugPrint(
          "🟡 [RATINGS] Raw response for product $productId: ${response.body}");

      if (response.isOk) {
        // Handle the actual API response structure
        if (response.body is Map<String, dynamic>) {
          final Map<String, dynamic> responseBody = response.body;

          // Check if the response has the expected structure
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final data = responseBody['data'];

            // The data might be nested under 'ratings' or directly as a list
            if (data is Map<String, dynamic> && data['ratings'] is List) {
              // Structure: {success: true, data: {ratings: [], totalPages: 1, ...}}
              final List<dynamic> ratingsList = data['ratings'];
              final List<Rating> ratings =
                  ratingsList.map((item) => Rating.fromJson(item)).toList();
              debugPrint("🟢 [RATINGS] Found ${ratings.length} ratings");
              return ratings;
            } else if (data is List) {
              // Structure: {success: true, data: []}
              final List<Rating> ratings =
                  data.map((item) => Rating.fromJson(item)).toList();
              debugPrint("🟢 [RATINGS] Found ${ratings.length} ratings");
              return ratings;
            }
          }
        }

        debugPrint("🟡 [RATINGS] No ratings found or unexpected format");
        return [];
      }

      debugPrint("🔴 [RATINGS] API call failed with status: ${response.statusCode}");
      return [];
    } catch (e) {
      debugPrint("🔴 [RATINGS] Error getting product ratings: $e");
      SnackBarHelper.showErrorSnackBar("Failed to load ratings: $e");
      return [];
    }
  }

  // Get rating stats for a product
  Future<Map<String, dynamic>?> getProductRatingStats(String productId) async {
    try {
      final response = await service.getItems(
        endpointUrl: 'ratings/product/$productId/stats',
      );

      debugPrint(
          "🟡 [STATS] Raw stats response for product $productId: ${response.body}");

      if (response.isOk) {
        if (response.body is Map<String, dynamic>) {
          final Map<String, dynamic> responseBody = response.body;

          if (responseBody['success'] == true && responseBody['data'] != null) {
            final stats = responseBody['data'];
            debugPrint("🟢 [STATS] Found stats: $stats");
            return stats;
          }
        }
      }

      debugPrint("🔴 [STATS] No stats found or API call failed");
      return null;
    } catch (e) {
      debugPrint("🔴 [STATS] Error getting rating stats: $e");
      return null;
    }
  }

  // Delete a rating
  deleteRating(String ratingId) async {
    try {
      Response response = await service.deleteItem(
        endpointUrl: 'ratings',
        itemId: ratingId,
      );

      if (response.isOk) {
        if (response.body is Map<String, dynamic>) {
          final responseBody = response.body as Map<String, dynamic>;
          if (responseBody['success'] == true) {
            SnackBarHelper.showSuccessSnackBar("Rating deleted successfully");
            updateUI();
          } else {
            SnackBarHelper.showErrorSnackBar(
              "Error: ${responseBody['message'] ?? 'Unknown error'}",
            );
          }
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
          "Error: ${response.statusText}",
        );
      }
    } catch (e) {
      debugPrint("🔴 [DELETE] Error deleting rating: $e");
      SnackBarHelper.showErrorSnackBar("Failed to delete rating: $e");
      rethrow;
    }
  }

  updateUI() {
    notifyListeners();
  }
}
