import 'package:admin_panal_start/screens/auth/login_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import '../../screens/main/main_screen.dart';

class AppPages {
  static const LOGIN = '/login';
  static const MAIN = '/main';

  static final routes = [
    GetPage(
      name: LOGIN,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: MAIN,
      page: () => MainScreen(),
    ),
  ];
}
