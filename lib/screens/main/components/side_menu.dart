import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../utility/extensions.dart';
import '../provider/main_screen_provider.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onItemSelected;
  final bool compact;

  const SideMenu({
    super.key,
    required this.onItemSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final AdminAuthService adminAuthService = Get.find<AdminAuthService>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: compact ? 80 : null,
      color: secondaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              compact ? 12 : 16,
              compact ? 16 : 28,
              compact ? 12 : 16,
              20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.06),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: compact
                ? ClipOval(
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.white.withOpacity(0.04),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/logo.png",
                        height: isMobile ? 44 : 52,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Marketplace Admin",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adminAuthService.currentAdmin?.name ?? "Administrator",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
          ),
          Consumer<MainScreenProvider>(
            builder: (context, provider, _) {
              return _buildMenuItems(context, provider.currentScreenName);
            },
          ),
          DrawerListTile(
            title: "Logout",
            icon: Icons.logout,
            compact: compact,
            press: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, String currentScreen) {
    final authService = Get.find<AdminAuthService>();
    final menuItems = [
      {"title": "Dashboard", "icon": Icons.dashboard, "screen": "Dashboard"},
      {"title": "Category", "icon": Icons.category, "screen": "Category"},
      {
        "title": "Sub Category",
        "icon": Icons.subdirectory_arrow_right,
        "screen": "SubCategory"
      },
      {"title": "Brands", "icon": Icons.branding_watermark, "screen": "Brands"},
      {
        "title": "Variant Type",
        "icon": Icons.type_specimen,
        "screen": "VariantType"
      },
      {"title": "Variants", "icon": Icons.widgets, "screen": "Variants"},
      {"title": "Orders", "icon": Icons.shopping_cart, "screen": "Order"},
      {
        "title": "Payment Verification",
        "icon": Icons.verified,
        "screen": "PaymentVerification"
      },
      {"title": "Posters", "icon": Icons.photo, "screen": "Poster"},
      {"title": "Ratings & Reviews", "icon": Icons.star, "screen": "Ratings"},
      {
        "title": "Notifications",
        "icon": Icons.notifications,
        "screen": "Notifications"
      },
    ];

    if (authService.canManageUsers()) {
      menuItems.add({
        "title": "User Management",
        "icon": Icons.people,
        "screen": "Users"
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: menuItems
          .map(
            (item) => DrawerListTile(
              title: item["title"] as String,
              icon: item["icon"] as IconData,
              compact: compact,
              active: currentScreen == item["screen"],
              press: () {
                context.mainScreenProvider
                    .navigateToScreen(item["screen"] as String);
                onItemSelected();
              },
            ),
          )
          .toList(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final adminAuthService = Get.find<AdminAuthService>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text(
          "Logout",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await adminAuthService.logout();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.press,
    this.compact = false,
    this.active = false,
    required this.icon,
  });

  final String title;
  final VoidCallback press;
  final bool compact;
  final bool active;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Colors.white.withOpacity(0.10);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 2 : 4,
      ),
      onTap: press,
      horizontalTitleGap: compact ? 0.0 : 16.0,
      leading: Icon(
        icon,
        color: active ? Colors.white : Colors.white54,
        size: compact ? 18 : 16,
      ),
      tileColor: active ? selectedColor : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      trailing: active
          ? Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(99),
              ),
            )
          : null,
      title: compact
          ? null
          : Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
    );
  }
}
