import '../../../models/sub_category.dart';
import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../provider/brand_provider.dart';
import '../../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../models/brand.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';

class BrandSubmitForm extends StatelessWidget {
  final Brand? brand;

  const BrandSubmitForm({super.key, this.brand});

  @override
  Widget build(BuildContext context) {
    context.brandProvider.setDataForUpdateBrand(brand);
    return SingleChildScrollView(
      child: Form(
        key: context.brandProvider.addBrandFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(ResponsiveUtils.getPadding(context)),
            _buildFormFields(context),
            Gap(ResponsiveUtils.getPadding(context) * 2),
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
          _buildSubCategoryDropdown(context),
          Gap(8),
          _buildNameField(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildSubCategoryDropdown(context)),
          Gap(8),
          Expanded(child: _buildNameField(context)),
        ],
      );
    }
  }

  Widget _buildSubCategoryDropdown(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, brandProvider, child) {
        return CustomDropdown(
          initialValue: brandProvider.selectedSubCategory,
          items: context.dataProvider.subCategories,
          hintText:
              brandProvider.selectedSubCategory?.name ?? 'Select Sub Category',
          displayItem: (SubCategory? subCategory) => subCategory?.name ?? '',
          onChanged: (newValue) {
            brandProvider.selectedSubCategory = newValue;
            brandProvider.updateUI();
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a Sub Category';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context) {
    return CustomTextField(
      controller: context.brandProvider.brandNameCtrl,
      labelText: 'Brand Name',
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a brand name';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: secondaryColor,
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
          ),
          onPressed: () {
            if (context.brandProvider.addBrandFormKey.currentState!
                .validate()) {
              context.brandProvider.addBrandFormKey.currentState!.save();
              context.brandProvider.submiteBrand();
              Navigator.of(context).pop();
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

void showBrandForm(BuildContext context, Brand? brand) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Add Brand',
        child: BrandSubmitForm(brand: brand),
      );
    },
  );
}
