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
  Widget _selectedScreen = const DashboardScreen();
  String _currentScreenName = 'Dashboard';

  Widget get selectedScreen => _selectedScreen;
  String get currentScreenName => _currentScreenName;

  void navigateToScreen(String screenName) {
    Widget newScreen;

    switch (screenName) {
      case 'Dashboard':
        newScreen = const DashboardScreen();
        break;
      case 'Category':
        newScreen = const CategoryScreen();
        break;
      case 'SubCategory':
        newScreen = const SubCategoryScreen();
        break;
      case 'Brands':
        newScreen = const BrandScreen();
        break;
      case 'VariantType':
        newScreen = const VariantsTypeScreen();
        break;
      case 'Variants':
        newScreen = const VariantsScreen();
        break;
      case 'Poster':
        newScreen = const PosterScreen();
        break;
      case 'Order':
        newScreen = const OrderScreen();
        break;
      case 'PaymentVerification':
        newScreen = const PaymentVerificationScreen();
        break;
      case 'Ratings':
        newScreen = const RatingsScreen();
        break;
      case 'Notifications':
        newScreen = const NotificationScreen();
        break;
      case 'Users':
        newScreen = const UsersScreen();
        break;
      default:
        newScreen = const DashboardScreen();
    }

    if (_selectedScreen.runtimeType != newScreen.runtimeType) {
      _selectedScreen = newScreen;
      _currentScreenName = screenName;
      notifyListeners();
    }
  }
}
