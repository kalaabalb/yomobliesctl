import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utility/constants.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType? inputType;
  final int? lineNumber;
  final void Function(String?)? onSave;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.onSave,
    this.inputType = TextInputType.text,
    this.lineNumber = 1,
    this.validator,
    required this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return TextFormField(
      controller: controller,
      maxLines: lineNumber,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: inputType,
      onSaved: onSave,
      validator: validator,
      inputFormatters: [
        LengthLimitingTextInputFormatter(700),
        if (inputType == TextInputType.number)
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      style: TextStyle(
        fontSize: isMobile ? 14 : 15,
        color: enabled ? Colors.white : Colors.white54,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 18,
          vertical: isMobile ? 14 : 16,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Container(
                margin: const EdgeInsetsDirectional.only(start: 12, end: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconTheme(
                  data: IconThemeData(color: Colors.grey.shade300),
                  child: prefixIcon!,
                ),
              ),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.65),
          fontSize: isMobile ? 13 : 14,
        ),
        helperStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
      ),
    );
  }
}
