import 'package:admin_panal_start/core/data/data_provider.dart';
import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/constants.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'components/side_menu.dart';
import 'provider/main_screen_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthentication();
    _startAutoRefresh();
  }

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_authService.isLoggedIn.value) {
        Get.offAllNamed('/login');
        return;
      }
      _refreshCurrentScreenData();
    });
  }

  void _refreshCurrentScreenData({bool force = false}) {
    if (!mounted || !_authService.isLoggedIn.value) return;

    final dataProvider = context.read<DataProvider>();
    final mainScreenProvider = context.read<MainScreenProvider>();
    dataProvider.refreshScreenData(
      mainScreenProvider.currentScreenName,
      forceRefresh: force,
    );
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 75), (_) {
      if (!mounted || !_authService.isLoggedIn.value) {
        return;
      }
      _refreshAppData();
    });
  }

  void _refreshAppData({bool force = false}) {
    _refreshCurrentScreenData(force: force);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAppData(force: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isLoggedIn.value) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      appBar: ResponsiveUtils.isMobile(context)
          ? AppBar(
              title: Consumer<MainScreenProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Admin Panel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        provider.currentScreenName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  );
                },
              ),
              backgroundColor: secondaryColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await _authService.logout();
                    Get.offAllNamed('/login');
                  },
                ),
              ],
            )
          : null,
      drawer: ResponsiveUtils.isMobile(context)
          ? _buildMobileDrawer(context)
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!ResponsiveUtils.isMobile(context))
              _buildDesktopSidebar(context),
            Expanded(
              flex: 5,
              child: Consumer<MainScreenProvider>(
                builder: (context, provider, child) {
                  return provider.selectedScreen;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: secondaryColor,
      width: MediaQuery.of(context).size.width * 0.88,
      child: SideMenu(
        onItemSelected: () {
          if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return SizedBox(
      width: ResponsiveUtils.isTablet(context) ? 80 : 250,
      child: SideMenu(
        onItemSelected: () {},
        compact: ResponsiveUtils.isTablet(context),
      ),
    );
  }
}
