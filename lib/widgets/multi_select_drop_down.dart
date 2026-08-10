// lib/widgets/multi_select_drop_down.dart
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../utility/constants.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';

class MultiSelectDropDown<T> extends StatefulWidget {
  final List<T> items;
  final Function(List<T>) onSelectionChanged;
  final String Function(T) displayItem;
  final List<T> selectedItems;
  final String? hintText;

  const MultiSelectDropDown({
    Key? key,
    required this.items,
    required this.onSelectionChanged,
    required this.displayItem,
    required this.selectedItems,
    this.hintText = 'Select items',
  }) : super(key: key);

  @override
  State<MultiSelectDropDown<T>> createState() => _MultiSelectDropDownState<T>();
}

class _MultiSelectDropDownState<T> extends State<MultiSelectDropDown<T>> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<T>(
          isExpanded: true,
          hint: Text(
            widget.hintText!,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          items: widget.items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: StatefulBuilder(
                builder: (context, menuSetState) {
                  final isSelected = widget.selectedItems.contains(item);
                  return Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.displayItem(item),
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
          value: null, // Always null to show hint
          onChanged: (T? value) {
            if (value != null) {
              setState(() {
                if (widget.selectedItems.contains(value)) {
                  widget.selectedItems.remove(value);
                } else {
                  widget.selectedItems.add(value);
                }
              });
              widget.onSelectionChanged(widget.selectedItems);
            }
          },
          buttonStyleData: ButtonStyleData(
            height: isMobile ? 44 : 52,
            padding: const EdgeInsets.only(left: 16, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.grey[50],
            ),
            elevation: 0,
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: isMobile ? MediaQuery.of(context).size.width * 0.8 : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            offset: Offset(0, -8),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          dropdownSearchData: widget.items.length > 5
              ? DropdownSearchData(
                  searchController: TextEditingController(),
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: TextEditingController(),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Search...',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return widget
                        .displayItem(item.value!)
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                )
              : null,
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              // Menu closed
            }
          },
        ),
      ),
    );
  }
}
