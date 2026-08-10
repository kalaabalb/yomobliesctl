import 'package:admin_panal_start/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../../widgets/responsive_header.dart';

class VariantTypeHeader extends StatelessWidget {
  const VariantTypeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Variant Types",
      onSearch: (val) => context.dataProvider.filterVariantTypes(val),
    );
  }
}
