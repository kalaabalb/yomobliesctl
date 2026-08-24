import 'package:admin_panal_start/screens/auth/login_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import '../../screens/main/main_screen.dart';

class AppPages {
  static const loginRoute = '/login';
  static const mainRoute = '/main';

  static final routes = [
    GetPage(
      name: loginRoute,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: mainRoute,
      page: () => const MainScreen(),
    ),
  ];
}
