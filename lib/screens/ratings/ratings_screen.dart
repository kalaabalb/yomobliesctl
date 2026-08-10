import 'package:admin_panal_start/models/product.dart';
import 'package:admin_panal_start/models/rating.dart';
import 'package:admin_panal_start/screens/ratings/provider/rating_provider.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../core/data/data_provider.dart';
import '../../utility/color_list.dart';
import '../../utility/constants.dart';
import '../../widgets/responsive_header.dart';

class RatingsScreen extends StatefulWidget {
  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-load products for ratings when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.dataProvider.products.isEmpty) {
        context.dataProvider.getAllProduct();
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
            RatingsHeader(),
            Gap(defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildRatingsHeader(context),
                      Gap(defaultPadding),
                      RatingsListSection(),
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

  Widget _buildRatingsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "Product Ratings & Reviews",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: () {
            context.dataProvider.getAllProduct(showSnack: true);
          },
          icon: Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class RatingsHeader extends StatelessWidget {
  const RatingsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Ratings & Reviews",
      onSearch: (val) {
        // Implement rating search when needed
      },
      actionButton: null,
    );
  }
}

class RatingsListSection extends StatelessWidget {
  const RatingsListSection({Key? key}) : super(key: key);

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
          Text("Product Ratings",
              style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: defaultPadding),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              if (dataProvider.products.isEmpty) {
                return Center(
                  child: Text(
                    "No products available",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ResponsiveDataTable(
                columns: [
                  DataColumn(label: Text("Product")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: List.generate(
                  dataProvider.products.length,
                  (index) => ratingDataRow(
                    dataProvider.products[index],
                    index + 1,
                    viewReviews: () {
                      _viewProductReviews(
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
}

DataRow ratingDataRow(Product productInfo, int index, {Function? viewReviews}) {
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
                productInfo.name ?? 'No Name',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      DataCell(
        IconButton(
          onPressed: () {
            if (viewReviews != null) viewReviews();
          },
          icon: Icon(Icons.remove_red_eye, color: Colors.blue, size: 20),
          tooltip: 'View Reviews',
        ),
      ),
    ],
  );
}

void _viewProductReviews(BuildContext context, Product product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<RatingProvider>(
        builder: (context, ratingProvider, child) {
          return Dialog(
            backgroundColor: secondaryColor,
            child: Container(
              width: ResponsiveUtils.isMobile(context) ? double.infinity : 800,
              height: 600,
              padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Reviews for ${product.name}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  Gap(defaultPadding),
                  Expanded(
                    child: FutureBuilder<List<Rating>>(
                      future: ratingProvider.getProductRatings(product.sId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error loading reviews",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final ratings = snapshot.data ?? [];

                        if (ratings.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.reviews, size: 64, color: Colors.grey),
                              Gap(16),
                              Text(
                                "No reviews yet",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 18),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          itemCount: ratings.length,
                          itemBuilder: (context, index) {
                            final rating = ratings[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.grey[800],
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(rating.userName?[0] ?? 'U'),
                                ),
                                title: Text(
                                  rating.userName ?? 'Unknown User',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  rating.review ?? 'No review text',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${rating.rating ?? 0}/5',
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                    Icon(Icons.star, color: Colors.amber),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
