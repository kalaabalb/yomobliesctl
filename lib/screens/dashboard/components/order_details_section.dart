import '../../../core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/responsive_utils.dart';
import '../../../utility/constants.dart';
import 'chart.dart';
import 'order_info_card.dart';

class OrderDetailsSection extends StatelessWidget {
  const OrderDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        int totalOrder = dataProvider.calculateOrdersWithStatus(null);
        int pendingOrder = dataProvider.calculateOrdersWithStatus('pending');
        int processingOrder = dataProvider.calculateOrdersWithStatus(
          'processing',
        );
        int cancelledOrder = dataProvider.calculateOrdersWithStatus(
          'cancelled',
        );
        int shippedOrder = dataProvider.calculateOrdersWithStatus('shipped');
        int deliveredOrder = dataProvider.calculateOrdersWithStatus(
          'delivered',
        );
        final isMobile = ResponsiveUtils.isMobile(context);
        return Container(
          padding: EdgeInsets.all(isMobile ? 12 : defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Orders Details",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: isMobile ? 10 : defaultPadding),
              SizedBox(
                height: isMobile ? 132 : 200,
                child: totalOrder == 0
                    ? Center(
                        child: Text(
                          'No order data yet',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white54,
                                  ),
                        ),
                      )
                    : const Chart(),
              ),
              SizedBox(height: isMobile ? 10 : defaultPadding),
              isMobile
                  ? GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 3.1,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery1.svg",
                          title: "All Orders",
                          totalOrder: totalOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery5.svg",
                          title: "Pending Orders",
                          totalOrder: pendingOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery6.svg",
                          title: "Processing",
                          totalOrder: processingOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery2.svg",
                          title: "Cancelled",
                          totalOrder: cancelledOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery4.svg",
                          title: "Shipped",
                          totalOrder: shippedOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery3.svg",
                          title: "Delivered",
                          totalOrder: deliveredOrder,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery1.svg",
                          title: "All Orders",
                          totalOrder: totalOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery5.svg",
                          title: "Pending Orders",
                          totalOrder: pendingOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery6.svg",
                          title: "Processed Orders",
                          totalOrder: processingOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery2.svg",
                          title: "Cancelled Orders",
                          totalOrder: cancelledOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery4.svg",
                          title: "Shipped Orders",
                          totalOrder: shippedOrder,
                        ),
                        OrderInfoCard(
                          svgSrc: "assets/icons/delivery3.svg",
                          title: "Delivered Orders",
                          totalOrder: deliveredOrder,
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}
