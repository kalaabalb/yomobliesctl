import 'package:admin_panal_start/models/order.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../core/data/data_provider.dart';
import '../../utility/color_list.dart';
import '../../utility/constants.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/responsive_header.dart';
import 'components/view_order_form.dart';

class OrderScreen extends StatefulWidget {
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedFilter = 'All orders';

  @override
  void initState() {
    super.initState();
    // Auto-load orders when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.dataProvider.orders.isEmpty) {
        context.dataProvider.getAllOrders();
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
            OrderHeader(),
            Gap(defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildOrderHeader(context),
                      Gap(defaultPadding),
                      OrderListSection(),
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

  Widget _buildOrderHeader(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "My Orders",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          Gap(8),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(context),
              ),
              Gap(8),
              IconButton(
                onPressed: () {
                  context.dataProvider.getAllOrders(showSnack: true);
                },
                icon: Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              "My Orders",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Gap(20),
          SizedBox(
            width: 280,
            child: _buildFilterDropdown(context),
          ),
          Gap(40),
          IconButton(
            onPressed: () {
              context.dataProvider.getAllOrders(showSnack: true);
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      );
    }
  }

  Widget _buildFilterDropdown(BuildContext context) {
    return CustomDropdown(
      hintText: 'Filter Orders',
      initialValue: _selectedFilter,
      items: [
        'All orders',
        'pending',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
        'payment_pending',
        'payment_verified',
      ],
      displayItem: (val) => val,
      onChanged: (newValue) {
        if (newValue == null) return;
        setState(() => _selectedFilter = newValue);
        if (newValue?.toLowerCase() == 'all orders') {
          context.dataProvider.filterOrders('');
        } else {
          context.dataProvider.filterOrders(newValue.toLowerCase());
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Please select status';
        }
        return null;
      },
    );
  }
}

class OrderHeader extends StatelessWidget {
  const OrderHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Orders",
      onSearch: (val) {
        context.dataProvider.filterOrders(val);
      },
      actionButton: null,
    );
  }
}

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
                    DataColumn(label: Text("Payment Status")),
                    DataColumn(label: Text("Order Status")),
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
        'ETB ${orderInfo.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(Text(
        orderInfo.paymentMethod?.toUpperCase() ?? 'N/A',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(Text(
        orderInfo.paymentStatus?.replaceAll('_', ' ').toUpperCase() ?? 'N/A',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      )),
      DataCell(Text(
        orderInfo.orderStatus?.replaceAll('_', ' ').toUpperCase() ?? '',
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
