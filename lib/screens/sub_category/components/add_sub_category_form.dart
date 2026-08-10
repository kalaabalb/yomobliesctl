import '../../../models/sub_category.dart';
import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../provider/sub_category_provider.dart';
import '../../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../models/category.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';

class SubCategorySubmitForm extends StatelessWidget {
  final SubCategory? subCategory;

  const SubCategorySubmitForm({super.key, this.subCategory});

  @override
  Widget build(BuildContext context) {
    context.subCategoryProvider.setDataForUpdateSubCategory(subCategory);
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Form(
        key: context.subCategoryProvider.addSubCategoryFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormFields(context),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          _buildCategoryDropdown(context),
          Gap(8),
          _buildNameField(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildCategoryDropdown(context)),
          Gap(8),
          Expanded(child: _buildNameField(context)),
        ],
      );
    }
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Consumer<SubCategoryProvider>(
      builder: (context, subCatProvider, child) {
        return CustomDropdown(
          initialValue: subCatProvider.selectedCategory,
          hintText: subCatProvider.selectedCategory?.name ?? 'Select category',
          items: context.dataProvider.categories,
          displayItem: (Category? category) => category?.name ?? '',
          onChanged: (newValue) {
            if (newValue != null) {
              subCatProvider.selectedCategory = newValue;
              subCatProvider.updateUI();
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context) {
    return CustomTextField(
      controller: context.subCategoryProvider.subCategoryNameCtrl,
      labelText: 'Sub Category Name',
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a sub category name';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: secondaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          Gap(ResponsiveUtils.getPadding(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              if (context
                  .subCategoryProvider.addSubCategoryFormKey.currentState!
                  .validate()) {
                context.subCategoryProvider.addSubCategoryFormKey.currentState!
                    .save();
                context.subCategoryProvider.submitSubCategory();
                Navigator.of(context).pop();
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

void showAddSubCategoryForm(BuildContext context, SubCategory? subCategory) {
  final isEditing = subCategory != null;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: isEditing ? 'Edit Sub Category' : 'Add Sub Category',
        child: SubCategorySubmitForm(subCategory: subCategory),
      );
    },
  );
}
