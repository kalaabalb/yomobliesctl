import '../../../utility/responsive_utils.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../provider/coupon_code_provider.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../models/category.dart';
import '../../../models/coupon.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_date_picker.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';

class CouponSubmitForm extends StatelessWidget {
  final Coupon? coupon;

  const CouponSubmitForm({Key? key, this.coupon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.couponCodeProvider.setDataForUpdateCoupon(coupon);
    return SingleChildScrollView(
      child: Form(
        key: context.couponCodeProvider.addCouponFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(ResponsiveUtils.getPadding(context)),
            _buildBasicInfoSection(context),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildAmountSection(context),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildDateStatusSection(context),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildApplicableSection(context),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          _buildCouponCodeField(context),
          Gap(8),
          _buildDiscountTypeDropdown(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildCouponCodeField(context)),
          Gap(8),
          Expanded(child: _buildDiscountTypeDropdown(context)),
        ],
      );
    }
  }

  Widget _buildCouponCodeField(BuildContext context) {
    return CustomTextField(
      controller: context.couponCodeProvider.couponCodeCtrl,
      labelText: 'Coupon Code',
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter coupon code';
        }
        return null;
      },
    );
  }

  Widget _buildDiscountTypeDropdown(BuildContext context) {
    return CustomDropdown(
      key: GlobalKey(),
      hintText: 'Discount Type',
      items: ['fixed', 'percentage'],
      initialValue: context.couponCodeProvider.selectedDiscountType,
      onChanged: (newValue) {
        context.couponCodeProvider.selectedDiscountType = newValue ?? 'fixed';
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a discount type';
        }
        return null;
      },
      displayItem: (val) => val,
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          _buildDiscountAmountField(context),
          Gap(8),
          _buildMinimumAmountField(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildDiscountAmountField(context)),
          Gap(8),
          Expanded(child: _buildMinimumAmountField(context)),
        ],
      );
    }
  }

  Widget _buildDiscountAmountField(BuildContext context) {
    return CustomTextField(
      controller: context.couponCodeProvider.discountAmountCtrl,
      labelText: 'Discount Amount',
      inputType: TextInputType.number,
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter discount amount';
        }
        return null;
      },
    );
  }

  Widget _buildMinimumAmountField(BuildContext context) {
    return CustomTextField(
      controller: context.couponCodeProvider.minimumPurchaseAmountCtrl,
      labelText: 'Minimum Purchase Amount',
      inputType: TextInputType.number,
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter minimum amount';
        }
        return null;
      },
    );
  }

  Widget _buildDateStatusSection(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          _buildDatePicker(context),
          Gap(8),
          _buildStatusDropdown(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildDatePicker(context)),
          Gap(8),
          Expanded(child: _buildStatusDropdown(context)),
        ],
      );
    }
  }

  Widget _buildDatePicker(BuildContext context) {
    return CustomDatePicker(
      labelText: 'Select Date',
      controller: context.couponCodeProvider.endDateCtrl,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      onDateSelected: (DateTime date) {
        print('Selected Date: $date');
      },
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return CustomDropdown(
      key: GlobalKey(),
      hintText: 'Status',
      initialValue: context.couponCodeProvider.selectedCouponStatus,
      items: ['active', 'inactive'],
      displayItem: (val) => val,
      onChanged: (newValue) {
        context.couponCodeProvider.selectedCouponStatus = newValue ?? 'active';
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select status';
        }
        return null;
      },
    );
  }

  Widget _buildApplicableSection(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          _buildCategoryDropdown(context),
          Gap(8),
          _buildSubCategoryDropdown(context),
          Gap(8),
          _buildProductDropdown(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildCategoryDropdown(context)),
          Gap(8),
          Expanded(child: _buildSubCategoryDropdown(context)),
          Gap(8),
          Expanded(child: _buildProductDropdown(context)),
        ],
      );
    }
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Consumer<CouponCodeProvider>(
      builder: (context, couponProvider, child) {
        return CustomDropdown(
          initialValue: couponProvider.selectedCategory,
          hintText: couponProvider.selectedCategory?.name ?? 'Select category',
          items: context.dataProvider.categories,
          displayItem: (Category? category) => category?.name ?? '',
          onChanged: (newValue) {
            if (newValue != null) {
              couponProvider.selectedSubCategory = null;
              couponProvider.selectedProduct = null;
              couponProvider.selectedCategory = newValue;
              couponProvider.updateUi();
            }
          },
        );
      },
    );
  }

  Widget _buildSubCategoryDropdown(BuildContext context) {
    return Consumer<CouponCodeProvider>(
      builder: (context, couponProvider, child) {
        return CustomDropdown(
          initialValue: couponProvider.selectedSubCategory,
          hintText:
              couponProvider.selectedSubCategory?.name ?? 'Select sub category',
          items: context.dataProvider.subCategories,
          displayItem: (SubCategory? subCategory) => subCategory?.name ?? '',
          onChanged: (newValue) {
            if (newValue != null) {
              couponProvider.selectedCategory = null;
              couponProvider.selectedProduct = null;
              couponProvider.selectedSubCategory = newValue;
              couponProvider.updateUi();
            }
          },
        );
      },
    );
  }

  Widget _buildProductDropdown(BuildContext context) {
    return Consumer<CouponCodeProvider>(
      builder: (context, couponProvider, child) {
        return CustomDropdown(
          initialValue: couponProvider.selectedProduct,
          hintText: couponProvider.selectedProduct?.name ?? 'Select product',
          items: context.dataProvider.products,
          displayItem: (Product? product) => product?.name ?? '',
          onChanged: (newValue) {
            if (newValue != null) {
              couponProvider.selectedCategory = null;
              couponProvider.selectedSubCategory = null;
              couponProvider.selectedProduct = newValue;
              couponProvider.updateUi();
            }
          },
        );
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
        SizedBox(width: ResponsiveUtils.getPadding(context)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
          ),
          onPressed: () {
            if (context.couponCodeProvider.addCouponFormKey.currentState!
                .validate()) {
              context.couponCodeProvider.addCouponFormKey.currentState!.save();
              context.couponCodeProvider.submitCoupon();
              Navigator.of(context).pop();
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

void showAddCouponForm(BuildContext context, Coupon? coupon) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Add Coupon',
        maxWidth: ResponsiveUtils.isMobile(context) ? double.infinity : 700,
        child: CouponSubmitForm(coupon: coupon),
      );
    },
  );
}
