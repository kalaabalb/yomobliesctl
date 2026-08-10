// lib/screens/order/components/order_list_section.dart
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import '../../../core/data/data_provider.dart';
import 'view_order_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../models/order.dart';
import '../../../utility/constants.dart';

class OrderListSection extends StatelessWidget {
  const OrderListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("All Order", style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                return ResponsiveDataTable(
                  columns: [
                    DataColumn(label: Text("Customer Name")),
                    DataColumn(label: Text("Order Amount")),
                    DataColumn(label: Text("Payment")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Edit")),
                    DataColumn(label: Text("Delete")),
                  ],
                  rows: List.generate(
                    dataProvider.orders.length,
                    (index) => orderDataRow(
                      dataProvider.orders[index],
                      index + 1,
                      delete: () {
                        context.orderProvider
                            .deleteOrder(dataProvider.orders[index]);
                      },
                      edit: () {
                        showOrderForm(context, dataProvider.orders[index]);
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

DataRow orderDataRow(Order orderInfo, int index,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                orderInfo.userID?.name ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      DataCell(Text(
        '${orderInfo.orderTotal?.total}',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(Text(
        orderInfo.paymentMethod ?? '',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(Text(
        orderInfo.orderStatus ?? '',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(Text(
        orderInfo.orderDate ?? '',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(
        IconButton(
          onPressed: () {
            if (edit != null) edit();
          },
          icon: Icon(Icons.edit, color: Colors.white),
        ),
      ),
      DataCell(
        IconButton(
          onPressed: () {
            if (delete != null) delete();
          },
          icon: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    ],
  );
}
