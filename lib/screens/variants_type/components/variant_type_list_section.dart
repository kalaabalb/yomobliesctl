import 'package:admin_panal_start/services/admin_auth_service.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/responsive_data_table.dart';
import 'package:get/get.dart';
import '../../../core/data/data_provider.dart';
import 'add_variant_type_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utility/color_list.dart';
import '../../../utility/constants.dart';
import '../../../models/variant_type.dart';

class VariantTypeListSection extends StatelessWidget {
  const VariantTypeListSection({Key? key}) : super(key: key);

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
          Text("All Variant Types",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: defaultPadding),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return ResponsiveDataTable(
                columns: const [
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Type")),
                  DataColumn(label: Text("Added Date")),
                  DataColumn(label: Text("Edit")),
                  DataColumn(label: Text("Delete")),
                ],
                rows: List.generate(
                  dataProvider.variantTypes.length,
                  (index) => variantTypeDataRow(
                    context,
                    dataProvider.variantTypes[index],
                    index + 1,
                    edit: () {
                      showAddVariantsTypeForm(
                          context, dataProvider.variantTypes[index]);
                    },
                    delete: () {
                      context.variantTypeProvider
                          .deleteVariantType(dataProvider.variantTypes[index]);
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

DataRow variantTypeDataRow(
    BuildContext context, VariantType variantTypeInfo, int index,
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
                  '$index',
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
                    variantTypeInfo.name ?? 'No Name',
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
              variantTypeInfo.type ?? 'N/A',
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
              _formatDate(variantTypeInfo.createdAt),
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
      DataCell(
        IconButton(
          onPressed: Get.find<AdminAuthService>().canEditItem(variantTypeInfo)
              ? () {
                  if (edit != null) edit();
                }
              : null,
          icon: Get.find<AdminAuthService>().canEditItem(variantTypeInfo)
              ? const Icon(Icons.edit, color: Colors.blue, size: 20)
              : const Icon(Icons.lock, color: Colors.grey, size: 20),
          tooltip: Get.find<AdminAuthService>().canEditItem(variantTypeInfo)
              ? 'Edit Variant Type'
              : 'No permission',
        ),
      ),
      DataCell(
        IconButton(
          onPressed: Get.find<AdminAuthService>().canDeleteItem(variantTypeInfo)
              ? () {
                  if (delete != null) delete();
                }
              : null,
          icon: Get.find<AdminAuthService>().canDeleteItem(variantTypeInfo)
              ? const Icon(Icons.delete, color: Colors.red, size: 20)
              : const Icon(Icons.lock, color: Colors.grey, size: 20),
          tooltip: Get.find<AdminAuthService>().canDeleteItem(variantTypeInfo)
              ? 'Delete Variant Type'
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
