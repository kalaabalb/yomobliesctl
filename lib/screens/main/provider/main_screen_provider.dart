import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../brands/brand_screen.dart';
import '../../category/category_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../notification/notification_screen.dart';
import '../../order/order_screen.dart';
import '../../payment_verification/payment_verification_screen.dart';
import '../../posters/poster_screen.dart';
import '../../ratings/ratings_screen.dart';
import '../../sub_category/sub_category_screen.dart';
import '../../users/users_screen.dart';
import '../../variants/variants_screen.dart';
import '../../variants_type/variants_type_screen.dart';

class MainScreenProvider extends ChangeNotifier {
  Widget _selectedScreen = DashboardScreen();
  String _currentScreenName = 'Dashboard';

  Widget get selectedScreen => _selectedScreen;
  String get currentScreenName => _currentScreenName;

  void navigateToScreen(String screenName) {
    Widget newScreen;

    switch (screenName) {
      case 'Dashboard':
        newScreen = DashboardScreen();
        break;
      case 'Category':
        newScreen = CategoryScreen();
        break;
      case 'SubCategory':
        newScreen = SubCategoryScreen();
        break;
      case 'Brands':
        newScreen = BrandScreen();
        break;
      case 'VariantType':
        newScreen = VariantsTypeScreen();
        break;
      case 'Variants':
        newScreen = VariantsScreen();
        break;
      case 'Poster':
        newScreen = PosterScreen();
        break;
      case 'Order':
        newScreen = OrderScreen();
        break;
      case 'PaymentVerification':
        newScreen = PaymentVerificationScreen();
        break;
      case 'Ratings':
        newScreen = RatingsScreen();
        break;
      case 'Notifications':
        newScreen = NotificationScreen();
        break;
      case 'Users':
        newScreen = UsersScreen();
        break;
      default:
        newScreen = DashboardScreen();
    }

    if (_selectedScreen.runtimeType != newScreen.runtimeType) {
      _selectedScreen = newScreen;
      _currentScreenName = screenName;
      notifyListeners();
    }
  }
}
