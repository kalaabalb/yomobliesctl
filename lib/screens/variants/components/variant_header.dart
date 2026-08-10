import 'package:admin_panal_start/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../../widgets/responsive_header.dart';

class VariantHeader extends StatelessWidget {
  const VariantHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Variants",
      onSearch: (val) => context.dataProvider.filterVariants(val),
    );
  }
}
