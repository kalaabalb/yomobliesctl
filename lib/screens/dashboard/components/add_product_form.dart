import 'dart:io';

import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../provider/dash_board_provider.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/multi_select_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/product_image_card.dart';

class ProductSubmitForm extends StatefulWidget {
  final Product? product;

  const ProductSubmitForm({super.key, this.product});

  @override
  State<ProductSubmitForm> createState() => _ProductSubmitFormState();
}

class _ProductSubmitFormState extends State<ProductSubmitForm> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialized) return;
      context.dashBoardProvider.setDataForUpdateProduct(widget.product);
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: context.dashBoardProvider.addProductFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSection(context),
            SizedBox(height: ResponsiveUtils.getPadding(context)),
            CustomTextField(
              controller: context.dashBoardProvider.productNameCtrl,
              labelText: 'Product Name',
              onSave: (val) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            SizedBox(height: ResponsiveUtils.getPadding(context)),
            CustomTextField(
              controller: context.dashBoardProvider.productDescCtrl,
              labelText: 'Product Description',
              lineNumber: 3,
              onSave: (val) {},
            ),
            SizedBox(height: ResponsiveUtils.getPadding(context)),
            _buildCategorySection(context),
            SizedBox(height: ResponsiveUtils.getPadding(context)),
            _buildPriceSection(context),
            SizedBox(height: ResponsiveUtils.getPadding(context)),
            _buildVariantSection(context),
            SizedBox(height: ResponsiveUtils.getPadding(context)),
            _buildActionButtons(context),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final images = [
      _ImageCardData('Main', 1, widget.product?.images.safeElementAt(0)?.url),
      _ImageCardData('Second', 2, widget.product?.images.safeElementAt(1)?.url),
      _ImageCardData('Third', 3, widget.product?.images.safeElementAt(2)?.url),
      _ImageCardData('Fourth', 4, widget.product?.images.safeElementAt(3)?.url),
      _ImageCardData('Fifth', 5, widget.product?.images.safeElementAt(4)?.url),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: images.map((imageData) {
              return Consumer<DashBoardProvider>(
                builder: (context, dashProvider, child) {
                  File? selectedImage;
                  switch (imageData.number) {
                    case 1:
                      selectedImage = dashProvider.selectedMainImage;
                      break;
                    case 2:
                      selectedImage = dashProvider.selectedSecondImage;
                      break;
                    case 3:
                      selectedImage = dashProvider.selectedThirdImage;
                      break;
                    case 4:
                      selectedImage = dashProvider.selectedFourthImage;
                      break;
                    case 5:
                      selectedImage = dashProvider.selectedFifthImage;
                      break;
                  }

                  return ProductImageCard(
                    labelText: imageData.label,
                    imageFile: selectedImage,
                    imageUrlForUpdateImage: imageData.imageUrl,
                    onTap: () {
                      dashProvider.pickImage(
                          imageCardNumber: imageData.number, context: context);
                    },
                    onRemoveImage: () {
                      switch (imageData.number) {
                        case 1:
                          dashProvider.selectedMainImage = null;
                          dashProvider.mainImgXFile = null;
                          break;
                        case 2:
                          dashProvider.selectedSecondImage = null;
                          dashProvider.secondImgXFile = null;
                          break;
                        case 3:
                          dashProvider.selectedThirdImage = null;
                          dashProvider.thirdImgXFile = null;
                          break;
                        case 4:
                          dashProvider.selectedFourthImage = null;
                          dashProvider.fourthImgXFile = null;
                          break;
                        case 5:
                          dashProvider.selectedFifthImage = null;
                          dashProvider.fifthImgXFile = null;
                          break;
                      }
                      dashProvider.updateUI();
                    },
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return ResponsiveUtils.isMobile(context)
        ? Column(
            children: [
              _buildCategoryDropdown(context),
              SizedBox(height: 8),
              _buildSubCategoryDropdown(context),
              SizedBox(height: 8),
              _buildBrandDropdown(context),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildCategoryDropdown(context)),
              SizedBox(width: 8),
              Expanded(child: _buildSubCategoryDropdown(context)),
              SizedBox(width: 8),
              Expanded(child: _buildBrandDropdown(context)),
            ],
          );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        return CustomDropdown(
          key: ValueKey('category_${dashProvider.selectedCategory?.sId}'),
          initialValue: dashProvider.selectedCategory,
          hintText: 'Select category',
          items: context.dataProvider.categories,
          displayItem: (Category? category) => category?.name ?? '',
          onChanged: (newValue) {
            context.dashBoardProvider.filterSubcategory(newValue);
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

  Widget _buildSubCategoryDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        return CustomDropdown(
          key: ValueKey(
              'subcategory_${dashProvider.selectedSubCategory?.sId}_${dashProvider.subCategoriesByCategory.length}'),
          hintText: 'Select sub category',
          items: dashProvider.subCategoriesByCategory,
          initialValue: dashProvider.selectedSubCategory,
          displayItem: (SubCategory? subCategory) => subCategory?.name ?? '',
          onChanged: (newValue) {
            context.dashBoardProvider.filterBrand(newValue);
          },
          validator: (value) {
            if (value == null &&
                dashProvider.subCategoriesByCategory.isNotEmpty) {
              return 'Please select sub category';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildBrandDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        return CustomDropdown(
          key: ValueKey(
              'brand_${dashProvider.selectedBrand?.sId}_${dashProvider.brandsBySubCategory.length}'),
          initialValue: dashProvider.selectedBrand,
          items: dashProvider.brandsBySubCategory,
          hintText: 'Select brand',
          displayItem: (Brand? brand) => brand?.name ?? '',
          onChanged: (newValue) {
            dashProvider.selectedBrand = newValue;
            dashProvider.updateUI();
          },
          validator: (value) {
            if (value == null && dashProvider.brandsBySubCategory.isNotEmpty) {
              return 'Please select brand';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return ResponsiveUtils.isMobile(context)
        ? Column(
            children: [
              CustomTextField(
                controller: context.dashBoardProvider.productPriceCtrl,
                labelText: 'Price',
                inputType: TextInputType.number,
                onSave: (val) {},
                validator: (value) {
                  if (value == null) {
                    return 'Please enter price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: context.dashBoardProvider.productOffPriceCtrl,
                labelText: 'Offer price',
                inputType: TextInputType.number,
                onSave: (val) {},
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: context.dashBoardProvider.productQntCtrl,
                labelText: 'Quantity',
                inputType: TextInputType.number,
                onSave: (val) {},
                validator: (value) {
                  if (value == null) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productPriceCtrl,
                  labelText: 'Price',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                  validator: (value) {
                    if (value == null) {
                      return 'Please enter price';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productOffPriceCtrl,
                  labelText: 'Offer price',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: context.dashBoardProvider.productQntCtrl,
                  labelText: 'Quantity',
                  inputType: TextInputType.number,
                  onSave: (val) {},
                  validator: (value) {
                    if (value == null) {
                      return 'Please enter quantity';
                    }
                    return null;
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildVariantSection(BuildContext context) {
    return ResponsiveUtils.isMobile(context)
        ? Column(
            children: [
              _buildVariantTypeDropdown(context),
              SizedBox(height: 8),
              _buildVariantMultiSelect(context),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildVariantTypeDropdown(context)),
              SizedBox(width: 8),
              Expanded(child: _buildVariantMultiSelect(context)),
            ],
          );
  }

  Widget _buildVariantTypeDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        return CustomDropdown(
          key:
              ValueKey('variant_type_${dashProvider.selectedVariantType?.sId}'),
          initialValue: dashProvider.selectedVariantType,
          items: context.dataProvider.variantTypes,
          displayItem: (VariantType? variantType) => variantType?.name ?? '',
          onChanged: (newValue) {
            context.dashBoardProvider.filterVariant(newValue);
          },
          hintText: 'Select variant type',
        );
      },
    );
  }

  Widget _buildVariantMultiSelect(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        return MultiSelectDropDown(
          key: ValueKey(
              'variants_${dashProvider.selectedVariantType?.sId}_${dashProvider.variantsByVariantType.length}'),
          items: dashProvider.variantsByVariantType,
          onSelectionChanged: (newValue) {
            dashProvider.selectedVariants = newValue;
            dashProvider.updateUI();
          },
          displayItem: (String item) => item,
          selectedItems: dashProvider.selectedVariants,
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
          SizedBox(width: ResponsiveUtils.getPadding(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              if (context.dashBoardProvider.addProductFormKey.currentState!
                  .validate()) {
                context.dashBoardProvider.addProductFormKey.currentState!
                    .save();
                context.dashBoardProvider.submitProduct();
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

class _ImageCardData {
  final String label;
  final int number;
  final String? imageUrl;

  _ImageCardData(this.label, this.number, this.imageUrl);
}

extension SafeList<T> on List<T>? {
  T? safeElementAt(int index) {
    if (this == null || index < 0 || index >= this!.length) {
      return null;
    }
    return this![index];
  }
}

Future<void> showAddProductForm(BuildContext context, Product? product) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Add Product',
        child: ProductSubmitForm(product: product),
      );
    },
  );
}
