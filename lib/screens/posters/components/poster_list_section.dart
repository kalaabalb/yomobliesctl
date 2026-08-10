import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../core/data/data_provider.dart';
import 'add_poster_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/poster.dart';
import '../../../utility/constants.dart';

class PosterListSection extends StatelessWidget {
  const PosterListSection({Key? key}) : super(key: key);

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
          Text("All Posters", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Consumer<DataProvider>(
              builder: (context, dataProvider, child) {
                if (dataProvider.posters.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posters found",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ResponsiveDataTable(
                  dataRowMinHeight: 70,
                  dataRowMaxHeight: 90,
                  columns: const [
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          "Image",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Expanded(
                        child: Text(
                          "Poster Name",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataColumn(label: Text("Edit")),
                    DataColumn(label: Text("Delete")),
                  ],
                  rows: List.generate(
                    dataProvider.posters.length,
                    (index) => posterDataRow(
                      context, // Add context
                      dataProvider.posters[index],
                      delete: () {
                        context.posterProvider
                            .deletePoster(dataProvider.posters[index]);
                      },
                      edit: () {
                        showAddPosterForm(context, dataProvider.posters[index]);
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

DataRow posterDataRow(BuildContext context, poster,
    {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Center(
            child: _buildPosterImage(poster.imageUrl),
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
                poster.posterName ?? 'No Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Center(
            child: Get.find<AdminAuthService>().canEditItem(poster)
                ? IconButton(
                    onPressed: () {
                      if (edit != null) edit();
                    },
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  )
                : const Icon(Icons.lock, color: Colors.grey, size: 20),
          ),
        ),
      ),
      DataCell(
        Container(
          constraints: const BoxConstraints(minHeight: 60),
          child: Center(
            child: Get.find<AdminAuthService>().canDeleteItem(poster)
                ? IconButton(
                    onPressed: () {
                      if (delete != null) delete();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  )
                : const Icon(Icons.lock, color: Colors.grey, size: 20),
          ),
        ),
      ),
    ],
  );
}

Widget _buildPosterImage(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'no_url') {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade600),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, color: Colors.grey, size: 16),
          SizedBox(height: 2),
          Text(
            'No Image',
            style: TextStyle(color: Colors.grey, fontSize: 8),
          ),
        ],
      ),
    );
  }

  return Container(
    width: 60,
    height: 40,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 60,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.red),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 16),
              SizedBox(height: 2),
              Text(
                'Error',
                style: TextStyle(color: Colors.red, fontSize: 8),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
