import 'package:admin_panal_start/utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../../widgets/responsive_header.dart';

class CouponCodeHeader extends StatelessWidget {
  const CouponCodeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Coupon Codes",
      onSearch: (val) => context.dataProvider.filterCoupons(val),
    );
  }
}
