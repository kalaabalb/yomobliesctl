import 'package:admin_panal_start/models/api_response.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/compact_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../models/admin_user.dart';
import '../../../services/admin_auth_service.dart';
import '../../../utility/constants.dart';
import '../../../utility/snack_bar_helper.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';

class UserSubmitForm extends StatefulWidget {
  final AdminUser? user;
  final Function()? onUserAdded;

  const UserSubmitForm({super.key, this.user, this.onUserAdded});

  @override
  State<UserSubmitForm> createState() => _UserSubmitFormState();
}

class _UserSubmitFormState extends State<UserSubmitForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _selectedClearanceLevel = 'admin';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final AdminAuthService _authService = Get.find<AdminAuthService>();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _setDataForUpdate(widget.user!);
    }
  }

  void _setDataForUpdate(AdminUser user) {
    _usernameCtrl.text = user.username ?? '';
    _nameCtrl.text = user.name ?? '';
    _emailCtrl.text = user.email ?? '';
    _selectedClearanceLevel = user.clearanceLevel ?? 'admin';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.user == null &&
        _passwordCtrl.text != _confirmPasswordCtrl.text) {
      SnackBarHelper.showErrorSnackBar('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = {
        'username': _usernameCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'clearanceLevel': _selectedClearanceLevel,
      };

      // Only include password for new users
      if (widget.user == null) {
        userData['password'] = _passwordCtrl.text;
      }

      print('🔄 Creating admin user with data: $userData');

      ApiResponse<AdminUser> result;

      if (widget.user != null) {
        print('📤 Updating user: ${widget.user!.sId}');
        result =
            await _authService.updateAdminUser(widget.user!.sId!, userData);
      } else {
        print('📤 Creating new user');
        result = await _authService.createAdminUser(userData);
      }

      print('📥 User creation response: ${result.success}');
      print('📥 User creation message: ${result.message}');

      if (result.success) {
        SnackBarHelper.showSuccessSnackBar(result.message);
        widget.onUserAdded?.call();
        Navigator.of(context).pop();
      } else {
        SnackBarHelper.showErrorSnackBar(result.message);
      }
    } catch (e) {
      print('❌ User creation error: $e');
      SnackBarHelper.showErrorSnackBar('Failed to save user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(ResponsiveUtils.getPadding(context)),

            // Username
            CustomTextField(
              controller: _usernameCtrl,
              labelText: 'Username',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return 'Username can only contain letters, numbers and underscore';
                }
                return null;
              },
            ),
            const Gap(12),

            // Full Name
            CustomTextField(
              controller: _nameCtrl,
              labelText: 'Full Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter full name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const Gap(12),

            // Email
            CustomTextField(
              controller: _emailCtrl,
              labelText: 'Email',
              inputType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const Gap(12),

            // Password (only for new users or when editing)
            if (!isEditing) ...[
              _buildPasswordField(
                controller: _passwordCtrl,
                labelText: 'Password',
                obscureText: _obscurePassword,
                onToggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const Gap(12),
              _buildPasswordField(
                controller: _confirmPasswordCtrl,
                labelText: 'Confirm Password',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              const Gap(12),
            ] else ...[
              // Optional password change for existing users
              _buildPasswordField(
                controller: _passwordCtrl,
                labelText: 'New Password (optional)',
                obscureText: _obscurePassword,
                onToggleVisibility: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                isOptional: true,
              ),
              const Gap(12),
            ],

            // Clearance Level
            CustomDropdown(
              hintText: 'Select clearance level',
              initialValue: _selectedClearanceLevel,
              items: const ['admin', 'super_admin'],
              displayItem: (val) =>
                  val == 'super_admin' ? 'Super Admin' : 'Admin',
              onChanged: (newValue) {
                setState(() {
                  _selectedClearanceLevel = newValue ?? 'admin';
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select clearance level';
                }
                return null;
              },
            ),

            Gap(ResponsiveUtils.getPadding(context) * 2),

            // Buttons
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.grey[700],
                            minimumSize: const Size(0, 50),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.getPadding(context)),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            minimumSize: const Size(0, 50),
                          ),
                          onPressed: _submitForm,
                          child:
                              Text(isEditing ? 'Update User' : 'Create User'),
                        ),
                      ),
                    ],
                  ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          labelText: labelText,
          obscureText: obscureText,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: onToggleVisibility,
          ),
          validator: isOptional
              ? null
              : (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
        ),
        if (isOptional)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 8),
            child: Text(
              'Leave empty to keep current password',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }
}

void showAddUserForm(BuildContext context, AdminUser? user,
    {Function()? onUserAdded}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: user == null ? 'Add Admin User' : 'Edit User',
        child: UserSubmitForm(user: user, onUserAdded: onUserAdded),
      );
    },
  );
}
