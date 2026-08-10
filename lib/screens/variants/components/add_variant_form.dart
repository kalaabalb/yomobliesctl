import '../../../models/variant.dart';
import '../../../models/variant_type.dart';
import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../provider/variant_provider.dart';
import '../../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../utility/extensions.dart';

class VariantSubmitForm extends StatelessWidget {
  final Variant? variant;

  const VariantSubmitForm({super.key, this.variant});

  @override
  Widget build(BuildContext context) {
    context.variantProvider.setDataForUpdateVariant(variant);
    return SingleChildScrollView(
      child: Form(
        key: context.variantProvider.addVariantFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: ResponsiveUtils.getPadding(context)),
            _buildFormFields(context),
            SizedBox(height: ResponsiveUtils.getPadding(context) * 2),
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
          _buildVariantTypeDropdown(context),
          SizedBox(height: 8),
          _buildNameField(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildVariantTypeDropdown(context)),
          SizedBox(width: 8),
          Expanded(child: _buildNameField(context)),
        ],
      );
    }
  }

  Widget _buildVariantTypeDropdown(BuildContext context) {
    return Consumer<VariantProvider>(
      builder: (context, variantProvider, child) {
        return CustomDropdown(
          initialValue: variantProvider.selectedVariantType,
          items: context.dataProvider.variantTypes,
          hintText: variantProvider.selectedVariantType?.name ??
              'Select Variant Type',
          displayItem: (VariantType? variantType) => variantType?.name ?? '',
          onChanged: (newValue) {
            variantProvider.selectedVariantType = newValue;
            variantProvider.updateUI();
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a Variant Type';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context) {
    return CustomTextField(
      controller: context.variantProvider.variantNameCtrl,
      labelText: 'Variant Name',
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a variant name';
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
        SizedBox(width: ResponsiveUtils.getPadding(context)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
          ),
          onPressed: () {
            if (context.variantProvider.addVariantFormKey.currentState!
                .validate()) {
              context.variantProvider.addVariantFormKey.currentState!.save();
              context.variantProvider.submitVariant();
              Navigator.of(context).pop();
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

void showAddVariantForm(BuildContext context, Variant? variant) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Add Variant',
        child: VariantSubmitForm(variant: variant),
      );
    },
  );
}
