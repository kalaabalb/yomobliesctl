import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../utility/responsive_utils.dart';
import '../utility/constants.dart';

class ResponsiveDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? dataRowMinHeight;
  final double? dataRowMaxHeight;

  const ResponsiveDataTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.dataRowMinHeight,
    this.dataRowMaxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileView(context);
    } else {
      return _buildDesktopView(context);
    }
  }

  Widget _buildDesktopView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: DataTable(
            columnSpacing: 8,
            horizontalMargin: 8,
            headingRowHeight: 46,
            dataRowMinHeight: dataRowMinHeight ?? 58,
            dataRowMaxHeight: dataRowMaxHeight ?? 76,
            dividerThickness: 0.6,
            showBottomBorder: false,
            columns: columns,
            rows: rows,
            dataTextStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            headingTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Gap(10),
      itemBuilder: (context, index) {
        final row = rows[index];
        final mobileFields = _collectMobileFields(row);
        final titleField = mobileFields.isNotEmpty ? mobileFields.first : null;
        final details = mobileFields.length > 1 ? mobileFields.sublist(1) : [];
        final actionFields = _collectActionFields(row);
        final imageField = _collectImageField(row);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                surfaceColor,
                surfaceAltColor.withOpacity(0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMobileTitle(titleField?.cell ?? row.cells.first),
              if (imageField != null) ...[
                const Gap(10),
                _buildMobileImageField(imageField),
              ],
              if (details.isNotEmpty) const Gap(8),
              for (final field in details.take(1))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 68,
                        child: Text(
                          field.label,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.64),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const Gap(6),
                      Expanded(
                          child: _buildMobileValue(field.cell, field.label)),
                    ],
                  ),
                ),
              if (details.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '+${details.length - 1} more',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (actionFields.isNotEmpty) ...[
                const Gap(8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: actionFields
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: field.cell.child,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getColumnLabel(DataColumn column) {
    if (column.label is Text) {
      return (column.label as Text).data ?? '';
    }
    return '';
  }

  List<_MobileField> _collectMobileFields(DataRow row) {
    final fields = <_MobileField>[];

    for (var i = 0; i < columns.length && i < row.cells.length; i++) {
      final label = _getColumnLabel(columns[i]);
      final normalized = label.toLowerCase();
      if (_isActionColumn(normalized)) {
        continue;
      }

      if (_isImageColumn(normalized)) {
        continue;
      }

      if (fields.isEmpty) {
        fields.add(_MobileField(label: label, cell: row.cells[i]));
        continue;
      }

      fields.add(_MobileField(label: label, cell: row.cells[i]));
    }

    return fields;
  }

  List<_MobileField> _collectActionFields(DataRow row) {
    final fields = <_MobileField>[];

    for (var i = 0; i < columns.length && i < row.cells.length; i++) {
      final label = _getColumnLabel(columns[i]);
      final normalized = label.toLowerCase();
      if (_isActionColumn(normalized)) {
        fields.add(_MobileField(label: label, cell: row.cells[i]));
      }
    }

    return fields;
  }

  _MobileField? _collectImageField(DataRow row) {
    for (var i = 0; i < columns.length && i < row.cells.length; i++) {
      final label = _getColumnLabel(columns[i]);
      final normalized = label.toLowerCase();
      if (_isImageColumn(normalized)) {
        return _MobileField(label: label, cell: row.cells[i]);
      }
    }

    return null;
  }

  bool _isActionColumn(String label) {
    return label.contains('edit') ||
        label.contains('delete') ||
        label.contains('view') ||
        label.contains('action') ||
        label.contains('actions');
  }

  bool _isImageColumn(String label) {
    return label.contains('image') ||
        label.contains('photo') ||
        label.contains('poster') ||
        label.contains('thumbnail');
  }

  Widget _buildMobileValue(DataCell cell, String label) {
    final child = cell.child;

    if (_isImageColumn(label.toLowerCase())) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 92, maxHeight: 68),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: child,
          ),
        ),
      );
    }

    return DefaultTextStyle.merge(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        height: 1.2,
      ),
      child: child,
    );
  }

  Widget _buildMobileImageField(_MobileField field) {
    final child = field.cell.child;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 68,
          child: Text(
            field.label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.64),
              fontWeight: FontWeight.w600,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ),
        const Gap(6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 92, maxHeight: 68),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTitle(DataCell cell) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        child: cell.child,
      ),
    );
  }
}

class _MobileField {
  final String label;
  final DataCell cell;

  const _MobileField({required this.label, required this.cell});
}
