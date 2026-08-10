import 'package:admin_panal_start/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../../widgets/responsive_header.dart';

class DashBoardHeader extends StatelessWidget {
  const DashBoardHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Dashboard",
      onSearch: (val) => context.dataProvider.filterProducts(val),
    );
  }
}
