import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../models/admin_user.dart';
import '../../services/admin_auth_service.dart';
import '../../utility/color_list.dart';
import '../../utility/constants.dart';
import '../../utility/snack_bar_helper.dart';
import '../../widgets/responsive_header.dart';
import 'components/add_user_form.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with WidgetsBindingObserver {
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  bool _initialLoadTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUsers(forceRefresh: true); // Reload when app comes to foreground
    }
  }

  Future<void> _loadUsers({bool forceRefresh = false}) async {
    if (!_authService.canManageUsers()) return;
    if (!forceRefresh &&
        _initialLoadTriggered &&
        _authService.allAdminUsers.isNotEmpty) {
      return;
    }

    _initialLoadTriggered = true;

    _isLoading.value = true;

    try {
      final result = await _authService.getAdminUsers();
      if (!result.success) {
        // User-friendly error message
        SnackBarHelper.showErrorSnackBar(result.message.isNotEmpty
            ? result.message
            : 'Failed to load users. Please pull down to refresh.');
      }
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          'Connection error. Please check your internet and try again.');
    } finally {
      _isLoading.value = false;
    }
  }

  List<AdminUser> get _filteredUsers {
    if (_searchQuery.isEmpty) return _authService.allAdminUsers;

    return _authService.allAdminUsers.where((user) {
      final query = _searchQuery.value.toLowerCase();
      return user.name?.toLowerCase().contains(query) == true ||
          user.username?.toLowerCase().contains(query) == true ||
          user.email?.toLowerCase().contains(query) == true;
    }).toList();
  }

  Future<void> _deleteUser(AdminUser user) async {
    final currentUser = _authService.currentUser;
    if (currentUser.value?.sId == user.sId) {
      SnackBarHelper.showErrorSnackBar('You cannot delete your own account');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text(
          "Delete User",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete ${user.name}? This will also delete all data created by this user. This action cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      _isLoading.value = true;
      try {
        final result = await _authService.deleteAdminUser(user.sId!);
        if (result.success) {
          SnackBarHelper.showSuccessSnackBar('User deleted successfully');
          await _loadUsers(forceRefresh: true);
        } else {
          SnackBarHelper.showErrorSnackBar(result.message);
        }
      } catch (e) {
        SnackBarHelper.showErrorSnackBar('Failed to delete user: $e');
      } finally {
        _isLoading.value = false;
      }
    }
  }

  Future<void> _toggleUserStatus(AdminUser user) async {
    final currentUser = _authService.currentUser;
    if (currentUser.value?.sId == user.sId) {
      SnackBarHelper.showErrorSnackBar(
          'You cannot deactivate your own account');
      return;
    }

    final newStatus = !(user.isActive ?? true);
    final action = newStatus ? 'activate' : 'deactivate';

    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          "$action User",
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to $action ${user.name}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.green : Colors.orange,
            ),
            child: Text(action.capitalizeFirst!),
          ),
        ],
      ),
    );

    if (shouldProceed == true) {
      _isLoading.value = true;
      try {
        final result = await _authService.updateAdminUser(user.sId!, {
          'isActive': newStatus,
        });
        if (result.success) {
          SnackBarHelper.showSuccessSnackBar('User ${action}ed successfully');
          await _loadUsers(forceRefresh: true);
        } else {
          SnackBarHelper.showErrorSnackBar(result.message);
        }
      } catch (e) {
        SnackBarHelper.showErrorSnackBar('Failed to $action user: $e');
      } finally {
        _isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          children: [
            _buildHeader(),
            const Gap(defaultPadding),
            _buildUserListSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final canManage = _authService.canManageUsers();
    return ResponsiveHeader(
      title: "User Management",
      onSearch: (val) {
        _searchQuery.value = val;
      },
      actionButton: canManage
          ? () => showAddUserForm(context, null, onUserAdded: _loadUsers)
          : null,
      actionButtonText: canManage ? "Add Admin" : null, // THIS IS REQUIRED
    );
  }

  Widget _buildUserListSection() {
    if (!_authService.canManageUsers()) {
      return _buildPermissionDenied();
    }

    return Obx(() {
      if (_isLoading.value) {
        return _buildLoading();
      }

      final users = _filteredUsers;

      return Container(
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        decoration: const BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Admin Users (${users.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Text('Search: ${_searchQuery.value}'),
                        onDeleted: () => _searchQuery.value = '',
                      ),
                    IconButton(
                      onPressed: _loadUsers,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
            const Gap(defaultPadding),
            if (users.isEmpty)
              _buildEmptyState()
            else
              ResponsiveDataTable(
                columns: const [
                  DataColumn(label: Text("User")),
                  DataColumn(label: Text("Email")),
                  DataColumn(label: Text("Role")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Created")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: List.generate(
                  users.length,
                  (index) => _userDataRow(users[index], index + 1),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPermissionDenied() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.admin_panel_settings, size: 64, color: Colors.white54),
            Gap(16),
            Text(
              "Super Admin Access Required",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Gap(8),
            Text(
              "Only super administrators can manage users",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.white54),
          const Gap(16),
          const Text(
            "No admin users found",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Gap(8),
          if (_searchQuery.isNotEmpty)
            Column(
              children: [
                Text(
                  "No users match '${_searchQuery.value}'",
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: () => _searchQuery.value = '',
                  child: const Text('Clear Search'),
                ),
              ],
            )
          else
            const Text(
              "Click 'Add Admin' to create the first user",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
        ],
      ),
    );
  }

  DataRow _userDataRow(AdminUser user, int index) {
    final currentUser = _authService.currentUser;
    final isCurrentUser = currentUser.value?.sId == user.sId;
    final isActive = user.isActive ?? true;

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.name ?? 'No Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            user.email ?? 'No email',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.isSuperAdmin ? Colors.purple : Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.isSuperAdmin ? 'Super Admin' : 'Admin',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            _formatDate(user.createdAt),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showAddUserForm(context, user, onUserAdded: _loadUsers);
                },
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                tooltip: 'Edit User',
              ),
              if (!isCurrentUser) ...[
                IconButton(
                  onPressed: () => _toggleUserStatus(user),
                  icon: Icon(
                    isActive ? Icons.person_off : Icons.person,
                    color: isActive ? Colors.orange : Colors.green,
                    size: 20,
                  ),
                  tooltip: isActive ? 'Deactivate User' : 'Activate User',
                ),
                IconButton(
                  onPressed: () => _deleteUser(user),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  tooltip: 'Delete User',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
