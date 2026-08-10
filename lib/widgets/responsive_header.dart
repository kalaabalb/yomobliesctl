import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/constants.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

class ResponsiveHeader extends StatelessWidget {
  final String title;
  final Function(String)? onSearch;
  final VoidCallback? actionButton;
  final String? actionButtonText;

  const ResponsiveHeader({
    super.key,
    required this.title,
    this.onSearch,
    this.actionButton,
    this.actionButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final AdminAuthService authService = Get.find<AdminAuthService>();
    final isMobile = ResponsiveUtils.isMobile(context);

    if (isMobile) {
      return Obx(() {
        final currentAdmin = authService.currentAdmin;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primaryColor,
                  child: Text(
                    currentAdmin?.name?.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Gap(2),
                      Text(
                        currentAdmin?.name ?? 'Admin',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onSearch != null) const Gap(12),
            if (onSearch != null)
              TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  hintText: "Search",
                  filled: true,
                  fillColor: secondaryColor,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                ),
              ),
            if (actionButton != null && actionButtonText != null) const Gap(12),
            if (actionButton != null && actionButtonText != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: actionButton,
                  icon: const Icon(Icons.add),
                  label: Text(actionButtonText!),
                ),
              ),
          ],
        );
      });
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (onSearch != null) ...[
          SizedBox(
            width: 320,
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: "Search",
                fillColor: secondaryColor,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
              ),
            ),
          ),
          const Gap(defaultPadding),
        ],
        if (actionButton != null && actionButtonText != null) ...[
          ElevatedButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding * 1.5,
                vertical: defaultPadding,
              ),
            ),
            onPressed: actionButton,
            icon: const Icon(Icons.add),
            label: Text(actionButtonText!),
          ),
          const Gap(20),
        ],
        Obx(() {
          final currentAdmin = authService.currentAdmin;
          return Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor,
                child: Text(
                  currentAdmin?.name?.substring(0, 1).toUpperCase() ?? 'A',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Gap(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentAdmin?.name ?? 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    currentAdmin?.clearanceLevel?.replaceAll('_', ' ') ??
                        'Admin',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }
}
