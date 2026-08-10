import 'package:admin_panal_start/utility/extensions.dart';

import '../../../core/data/data_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/responsive_utils.dart';
import '../../../utility/constants.dart';

class Chart extends StatelessWidget {
  const Chart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return SizedBox(
      height: isMobile ? 112 : 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: isMobile ? 32 : 70,
              startDegreeOffset: -90,
              sections: _buildPieChartSelectionData(context),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isMobile ? 6 : defaultPadding),
                Consumer<DataProvider>(
                  builder: (context, dataProvider, child) {
                    return Text(
                      '${context.dataProvider.calculateOrdersWithStatus(null)}',
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 0.8,
                                fontSize: isMobile ? 22 : null,
                              ),
                    );
                  },
                ),
                SizedBox(height: isMobile ? 4 : defaultPadding),
                Text(
                  "Orders",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSelectionData(BuildContext context) {
    Provider.of<DataProvider>(context);
    context.dataProvider.calculateOrdersWithStatus(null);
    int pendingOrder = context.dataProvider.calculateOrdersWithStatus(
      'pending',
    );
    int processingOrder = context.dataProvider.calculateOrdersWithStatus(
      'processing',
    );
    int cancelledOrder = context.dataProvider.calculateOrdersWithStatus(
      'cancelled',
    );
    int shippedOrder = context.dataProvider.calculateOrdersWithStatus(
      'shipped',
    );
    int deliveredOrder = context.dataProvider.calculateOrdersWithStatus(
      'delivered',
    );

    List<PieChartSectionData> pieChartSelectionData = [
      PieChartSectionData(
        color: Color(0xFFFFCF26),
        value: pendingOrder.toDouble(),
        showTitle: false,
        radius: 20,
      ),
      PieChartSectionData(
        color: Color(0xFFEE2727),
        value: cancelledOrder.toDouble(),
        showTitle: false,
        radius: 20,
      ),
      PieChartSectionData(
        color: Color(0xFF2697FF),
        value: shippedOrder.toDouble(),
        showTitle: false,
        radius: 20,
      ),
      PieChartSectionData(
        color: Color(0xFF26FF31),
        value: deliveredOrder.toDouble(),
        showTitle: false,
        radius: 20,
      ),
      PieChartSectionData(
        color: Colors.white,
        value: processingOrder.toDouble(),
        showTitle: false,
        radius: 20,
      ),
    ];

    return pieChartSelectionData;
  }
}
