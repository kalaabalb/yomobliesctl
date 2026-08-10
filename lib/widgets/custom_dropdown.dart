// lib/widgets/custom_dropdown.dart - Updated
import 'package:flutter/material.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? initialValue;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String hintText;
  final String Function(T) displayItem;
  final bool isExpanded;

  const CustomDropdown({
    Key? key,
    this.initialValue,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hintText = 'Select an option',
    required this.displayItem,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolvedValue =
        items.any((item) => item == initialValue) ? initialValue : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: DropdownButtonFormField<T>(
        isExpanded: isExpanded,
        decoration: InputDecoration(
          labelText: hintText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: ResponsiveUtils.isMobile(context) ? 10 : 14,
          ),
        ),
        value: resolvedValue,
        items: items.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(
              displayItem(value),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveUtils.isMobile(context) ? 14 : 16,
                color: Colors.white,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(
          fontSize: ResponsiveUtils.isMobile(context) ? 14 : 16,
          color: Colors.white,
        ),
        dropdownColor: Color(0xFF2A2D3E),
        icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
      ),
    );
  }
}
