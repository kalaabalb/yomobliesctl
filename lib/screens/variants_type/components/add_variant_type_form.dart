import '../../../models/variant_type.dart';
import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../../../utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_text_field.dart';

class VariantTypeSubmitForm extends StatelessWidget {
  final VariantType? variantType;

  const VariantTypeSubmitForm({super.key, this.variantType});

  @override
  Widget build(BuildContext context) {
    context.variantTypeProvider.setDataForUpdateVariantType(variantType);
    return SingleChildScrollView(
      child: Form(
        key: context.variantTypeProvider.addVariantTypeFormKey,
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
          _buildNameField(context),
          SizedBox(height: 8),
          _buildTypeField(context),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildNameField(context)),
          SizedBox(width: 8),
          Expanded(child: _buildTypeField(context)),
        ],
      );
    }
  }

  Widget _buildNameField(BuildContext context) {
    return CustomTextField(
      controller: context.variantTypeProvider.variantTypeNameCtrl,
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

  Widget _buildTypeField(BuildContext context) {
    return CustomTextField(
      controller: context.variantTypeProvider.variantTypeTypeCtrl,
      labelText: 'Variant Type',
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a type name';
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
            if (context.variantTypeProvider.addVariantTypeFormKey.currentState!
                .validate()) {
              context.variantTypeProvider.addVariantTypeFormKey.currentState!
                  .save();
              context.variantTypeProvider.submitVariantType();
              Navigator.of(context).pop();
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

void showAddVariantsTypeForm(BuildContext context, VariantType? variantType) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Add Variant Type',
        child: VariantTypeSubmitForm(variantType: variantType),
      );
    },
  );
}
