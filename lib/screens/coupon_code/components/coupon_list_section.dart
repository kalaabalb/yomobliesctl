import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/coupon.dart';
import 'add_coupon_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';

class CouponListSection extends StatelessWidget {
  const CouponListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("All Coupons", style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                return ResponsiveDataTable(
                  columns: const [
                    DataColumn(label: Text("Coupon Name")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Type")),
                    DataColumn(label: Text("Amount")),
                    DataColumn(label: Text("Edit")),
                    DataColumn(label: Text("Delete")),
                  ],
                  rows: List.generate(
                    dataProvider.coupons.length,
                    (index) => couponDataRow(
                      context, // Add context
                      dataProvider.coupons[index],
                      index + 1,
                      edit: () {
                        showAddCouponForm(context, dataProvider.coupons[index]);
                      },
                      delete: () {
                        context.couponCodeProvider
                            .deleteCoupon(dataProvider.coupons[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

DataRow couponDataRow(BuildContext context, coupon, int index,
    {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
              child: Text(index.toString(), textAlign: TextAlign.center),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Coupon Code',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      const DataCell(Text(
        'Status',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      const DataCell(Text(
        'Type',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      const DataCell(Text(
        'Amount',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(
        IconButton(
          onPressed: Get.find<AdminAuthService>().canEditItem(coupon)
              ? () {
                  if (edit != null) edit();
                }
              : null,
          icon: Get.find<AdminAuthService>().canEditItem(coupon)
              ? const Icon(Icons.edit, color: Colors.white)
              : const Icon(Icons.lock, color: Colors.grey),
        ),
      ),
      DataCell(
        IconButton(
          onPressed: Get.find<AdminAuthService>().canDeleteItem(coupon)
              ? () {
                  if (delete != null) delete();
                }
              : null,
          icon: Get.find<AdminAuthService>().canDeleteItem(coupon)
              ? const Icon(Icons.delete, color: Colors.red)
              : const Icon(Icons.lock, color: Colors.grey),
        ),
      ),
    ],
  );
}
