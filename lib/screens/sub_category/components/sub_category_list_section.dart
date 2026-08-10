import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../core/data/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import '../../../models/sub_category.dart';
import 'add_sub_category_form.dart';

class SubCategoryListSection extends StatelessWidget {
  const SubCategoryListSection({Key? key}) : super(key: key);

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
          Text("All Sub Categories",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: defaultPadding),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return ResponsiveDataTable(
                columns: const [
                  DataColumn(label: Text("Sub Category")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Added Date")),
                  DataColumn(label: Text("Edit")),
                  DataColumn(label: Text("Delete")),
                ],
                rows: List.generate(
                  dataProvider.subCategories.length,
                  (index) => subCategoryDataRow(
                    context, // Add context
                    dataProvider.subCategories[index],
                    index + 1,
                    edit: () {
                      showAddSubCategoryForm(
                        context,
                        dataProvider.subCategories[index],
                      );
                    },
                    delete: () {
                      context.subCategoryProvider
                          .deleteSubCategory(dataProvider.subCategories[index]);
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

DataRow subCategoryDataRow(
    BuildContext context, SubCategory subCategoryInfo, int index,
    {Function? edit, Function? delete}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subCategoryInfo.name ?? 'No Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subCategoryInfo.categoryId?.name ?? 'N/A',
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(subCategoryInfo.createdAt),
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
      DataCell(
        IconButton(
          onPressed: Get.find<AdminAuthService>().canEditItem(subCategoryInfo)
              ? () {
                  if (edit != null) edit();
                }
              : null,
          icon: Get.find<AdminAuthService>().canEditItem(subCategoryInfo)
              ? const Icon(Icons.edit, color: Colors.blue, size: 20)
              : const Icon(Icons.lock, color: Colors.grey, size: 20),
          tooltip: Get.find<AdminAuthService>().canEditItem(subCategoryInfo)
              ? 'Edit Sub Category'
              : 'No permission',
        ),
      ),
      DataCell(
        IconButton(
          onPressed: Get.find<AdminAuthService>().canDeleteItem(subCategoryInfo)
              ? () {
                  if (delete != null) delete();
                }
              : null,
          icon: Get.find<AdminAuthService>().canDeleteItem(subCategoryInfo)
              ? const Icon(Icons.delete, color: Colors.red, size: 20)
              : const Icon(Icons.lock, color: Colors.grey, size: 20),
          tooltip: Get.find<AdminAuthService>().canDeleteItem(subCategoryInfo)
              ? 'Delete Sub Category'
              : 'No permission',
        ),
      ),
    ],
  );
}

String _formatDate(String? dateString) {
  if (dateString == null) return 'N/A';
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateString;
  }
}
