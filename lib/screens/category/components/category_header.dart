import 'package:admin_panal_start/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../../widgets/responsive_header.dart';

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Category",
      onSearch: (val) => context.dataProvider.filterCategories(val),
    );
  }
}
