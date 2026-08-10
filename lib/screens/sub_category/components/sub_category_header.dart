import 'package:admin_panal_start/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../../widgets/responsive_header.dart';

class SubCategoryHeader extends StatelessWidget {
  const SubCategoryHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Sub Category",
      onSearch: (val) => context.dataProvider.filteredSubCategories(val),
    );
  }
}
