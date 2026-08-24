import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utility/constants.dart';
import 'components/add_sub_category_form.dart';
import 'components/sub_category_header.dart';
import 'components/sub_category_list_section.dart';

class SubCategoryScreen extends StatefulWidget {
  const SubCategoryScreen({super.key});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-load subcategories when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.dataProvider.subCategories.isEmpty) {
        context.dataProvider.getAllSubCategory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          children: [
            const SubCategoryHeader(),
            const Gap(defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "My Sub Categories",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.isMobile(context)
                                    ? defaultPadding
                                    : defaultPadding * 1.5,
                                vertical: ResponsiveUtils.isMobile(context)
                                    ? defaultPadding / 2
                                    : defaultPadding,
                              ),
                            ),
                            onPressed: () {
                              showAddSubCategoryForm(context, null);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add New"),
                          ),
                          Gap(ResponsiveUtils.isMobile(context) ? 8 : 20),
                          IconButton(
                            onPressed: () {
                              context.dataProvider
                                  .getAllSubCategory(showSnack: true);
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const Gap(defaultPadding),
                      const SubCategoryListSection(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
