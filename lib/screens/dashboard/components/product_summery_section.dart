import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/product_summery_info.dart';
import '../../../utility/constants.dart';
import 'product_summery_card.dart';

class ProductSummerySection extends StatelessWidget {
  const ProductSummerySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        int totalProduct =
            context.dataProvider.calculateProductWithQuantity(null);
        int outOfStockProduct =
            context.dataProvider.calculateProductWithQuantity(0);
        int limitedStockProduct =
            context.dataProvider.calculateProductWithQuantity(1);
        int otherStockProduct =
            totalProduct - outOfStockProduct - limitedStockProduct;

        List<ProductSummeryInfo> productSummeryItems = [
          ProductSummeryInfo(
            title: "All Product",
            productsCount: totalProduct,
            svgSrc: "assets/icons/Product.svg",
            color: primaryColor,
            percentage: 100,
          ),
          ProductSummeryInfo(
            title: "Out of Stock",
            productsCount: outOfStockProduct,
            svgSrc: "assets/icons/Product2.svg",
            color: Color(0xFFEA3829),
            percentage: totalProduct != 0
                ? (outOfStockProduct / totalProduct) * 100
                : 0,
          ),
          ProductSummeryInfo(
            title: "Limited Stock",
            productsCount: limitedStockProduct,
            svgSrc: "assets/icons/Product3.svg",
            color: Color(0xFFECBE23),
            percentage: totalProduct != 0
                ? (limitedStockProduct / totalProduct) * 100
                : 0,
          ),
          ProductSummeryInfo(
            title: "Other Stock",
            productsCount: otherStockProduct,
            svgSrc: "assets/icons/Product4.svg",
            color: Color(0xFF47e228),
            percentage: totalProduct != 0
                ? (otherStockProduct / totalProduct) * 100
                : 0,
          ),
        ];

        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: productSummeryItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.isMobile(context)
                ? 2
                : ResponsiveUtils.getGridCrossAxisCount(context),
            crossAxisSpacing:
                ResponsiveUtils.isMobile(context) ? 8 : defaultPadding,
            mainAxisSpacing:
                ResponsiveUtils.isMobile(context) ? 8 : defaultPadding,
            childAspectRatio: _getAspectRatio(context),
          ),
          itemBuilder: (context, index) => ProductSummeryCard(
            info: productSummeryItems[index],
            onTap: (productType) {
              context.dataProvider.filterProductsByQuantity(productType ?? '');
            },
          ),
        );
      },
    );
  }

  double _getAspectRatio(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) return 1.55;
    if (ResponsiveUtils.isTablet(context)) return 1.18;
    return 1.28;
  }
}
