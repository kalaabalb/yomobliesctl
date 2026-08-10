import '../../../models/category.dart';
import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../provider/category_provider.dart';
import '../../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../../../widgets/category_image_card.dart';
import '../../../widgets/custom_text_field.dart';

class CategorySubmitForm extends StatelessWidget {
  final Category? category;

  const CategorySubmitForm({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    context.categoryProvider.setDataForUpdateCategory(category);
    return Form(
      key: context.categoryProvider.addCategoryFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSection(context),
            Gap(ResponsiveUtils.getPadding(context)),
            CustomTextField(
              controller: context.categoryProvider.categoryNameCtrl,
              labelText: 'Category Name',
              onSave: (val) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildActionButtons(context),
            SizedBox(height: 8), // Small bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, catProvider, child) {
        return Column(
          children: [
            SizedBox(
              width: ResponsiveUtils.isMobile(context) ? 120 : 150,
              child: CategoryImageCard(
                labelText: "Category",
                imageFile: catProvider.selectedImage,
                imageUrlForUpdateImage: category?.image,
                onTap: () {
                  catProvider.pickImage(context);
                },
                onRemoveImage: () {
                  catProvider.selectedImage = null;
                  catProvider.imgXFile = null;
                },
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap to add category image',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 8),
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
              if (context.categoryProvider.addCategoryFormKey.currentState!
                  .validate()) {
                context.categoryProvider.addCategoryFormKey.currentState!
                    .save();
                context.categoryProvider.submitCategory();
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

void showAddCategoryForm(BuildContext context, Category? category) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Add Category',
        child: CategorySubmitForm(category: category),
      );
    },
  );
}
