import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../utility/constants.dart';
import 'components/add_variant_form.dart';
import 'components/variant_header.dart';
import 'components/variants_list_section.dart';

class VariantsScreen extends StatefulWidget {
  @override
  State<VariantsScreen> createState() => _VariantsScreenState();
}

class _VariantsScreenState extends State<VariantsScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-load variants when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.dataProvider.variants.isEmpty) {
        context.dataProvider.getAllVariant();
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
            VariantHeader(),
            Gap(defaultPadding),
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
                              "My Variants",
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
                              showAddVariantForm(context, null);
                            },
                            icon: Icon(Icons.add),
                            label: Text("Add New"),
                          ),
                          Gap(ResponsiveUtils.isMobile(context) ? 8 : 20),
                          IconButton(
                            onPressed: () {
                              context.dataProvider
                                  .getAllVariant(showSnack: true);
                            },
                            icon: Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      Gap(defaultPadding),
                      VariantListSection(),
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
