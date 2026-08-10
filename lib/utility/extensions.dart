import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/data/data_provider.dart';
import '../screens/main/provider/main_screen_provider.dart';
import '../screens/category/provider/category_provider.dart';
import '../screens/sub_category/provider/sub_category_provider.dart';
import '../screens/brands/provider/brand_provider.dart';
import '../screens/variants_type/provider/variant_type_provider.dart';
import '../screens/variants/provider/variant_provider.dart';
import '../screens/dashboard/provider/dash_board_provider.dart';
import '../screens/coupon_code/provider/coupon_code_provider.dart';
import '../screens/posters/provider/poster_provider.dart';
import '../screens/order/provider/order_provider.dart';
import '../screens/ratings/provider/rating_provider.dart';
import '../screens/notification/provider/notification_provider.dart';
import '../services/admin_auth_service.dart';

extension ContextExtensions on BuildContext {
  DataProvider get dataProvider =>
      Provider.of<DataProvider>(this, listen: false);

  MainScreenProvider get mainScreenProvider =>
      Provider.of<MainScreenProvider>(this, listen: false);

  CategoryProvider get categoryProvider =>
      Provider.of<CategoryProvider>(this, listen: false);

  SubCategoryProvider get subCategoryProvider =>
      Provider.of<SubCategoryProvider>(this, listen: false);

  BrandProvider get brandProvider =>
      Provider.of<BrandProvider>(this, listen: false);

  VariantTypeProvider get variantTypeProvider =>
      Provider.of<VariantTypeProvider>(this, listen: false);

  VariantProvider get variantProvider =>
      Provider.of<VariantProvider>(this, listen: false);

  DashBoardProvider get dashBoardProvider =>
      Provider.of<DashBoardProvider>(this, listen: false);

  CouponCodeProvider get couponCodeProvider =>
      Provider.of<CouponCodeProvider>(this, listen: false);

  PosterProvider get posterProvider =>
      Provider.of<PosterProvider>(this, listen: false);

  OrderProvider get orderProvider =>
      Provider.of<OrderProvider>(this, listen: false);

  RatingProvider get ratingProvider =>
      Provider.of<RatingProvider>(this, listen: false);

  NotificationProvider get notificationProvider =>
      Provider.of<NotificationProvider>(this, listen: false);
}
