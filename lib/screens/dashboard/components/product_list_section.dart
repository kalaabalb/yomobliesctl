import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/product.dart';
import 'add_product_form.dart';
import '../../../utility/constants.dart';

class ProductListSection extends StatelessWidget {
  const ProductListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("All Products",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  return Text(
                    "${dataProvider.products.length} products",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              if (dataProvider.products.isEmpty) {
                return _buildEmptyState(context);
              }

              return ResponsiveDataTable(
                dataRowMinHeight: 60,
                dataRowMaxHeight: 78,
                columns: const [
                  DataColumn(label: Text("Product")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Stock")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Edit")),
                  DataColumn(label: Text("Delete")),
                ],
                rows: List.generate(
                  dataProvider.products.length,
                  (index) => productDataRow(
                    context,
                    dataProvider.products[index],
                    index + 1,
                    edit: () {
                      showAddProductForm(context, dataProvider.products[index]);
                    },
                    delete: () {
                      _showDeleteConfirmation(
                          context, dataProvider.products[index]);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Products Found",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your first product to get started",
            style: const TextStyle(
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              showAddProductForm(context, null);
            },
            icon: const Icon(Icons.add),
            label: const Text("Add First Product"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Product",
              style: const TextStyle(color: Colors.white)),
          backgroundColor: secondaryColor,
          content: Text(
            "Are you sure you want to delete '${product.name}'? This action cannot be undone.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel",
                  style: const TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.dashBoardProvider.deleteProduct(product);
              },
              child: const Text("Delete",
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

DataRow productDataRow(BuildContext context, Product productInfo, int index,
    {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: _buildProductImage(productInfo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productInfo.name ?? 'Unnamed Product',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (productInfo.description != null &&
                        productInfo.description!.isNotEmpty)
                      Text(
                        productInfo.description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'By: ${productInfo.createdByName}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productInfo.proCategoryId?.name ?? 'No Category',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              if (productInfo.proSubCategoryId?.name != null)
                Text(
                  productInfo.proSubCategoryId!.name!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
      ),
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStockStatusColor(productInfo),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  productInfo.stockStatus.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${productInfo.quantity ?? 0} in stock',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${productInfo.price?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (productInfo.hasDiscount) ...[
                const SizedBox(height: 2),
                Text(
                  '\$${productInfo.offerPrice?.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  '${productInfo.discountPercentage.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Center(
            child: Get.find<AdminAuthService>().canEditItem(productInfo)
                ? IconButton(
                    onPressed: () {
                      if (edit != null) edit();
                    },
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    tooltip: 'Edit Product',
                  )
                : const Tooltip(
                    message: "You can only edit your own products",
                    child:
                        Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                  ),
          ),
        ),
      ),
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Center(
            child: Get.find<AdminAuthService>().canDeleteItem(productInfo)
                ? IconButton(
                    onPressed: () {
                      if (delete != null) delete();
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    tooltip: 'Delete Product',
                  )
                : const Tooltip(
                    message: "You can only delete your own products",
                    child:
                        Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                  ),
          ),
        ),
      ),
    ],
  );
}

Color _getStockStatusColor(Product product) {
  if (product.quantity == null || product.quantity! <= 0) {
    return Colors.red.withOpacity(0.8);
  } else if (product.quantity! <= 5) {
    return Colors.orange.withOpacity(0.8);
  } else {
    return Colors.green.withOpacity(0.8);
  }
}

Widget _buildProductImage(Product product) {
  final hasImages = product.images != null &&
      product.images!.isNotEmpty &&
      product.images![0].url != null &&
      product.images![0].url!.isNotEmpty;

  if (!hasImages) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[700],
      ),
      child: Icon(Icons.image, color: Colors.grey[400], size: 24),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: CachedNetworkImage(
      imageUrl: product.images![0].url!,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[800],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[700],
        child: const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 20,
        ),
      ),
    ),
  );
}
