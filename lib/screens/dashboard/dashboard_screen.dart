import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import 'components/add_product_form.dart';
import 'components/dash_board_header.dart';
import 'components/order_details_section.dart';
import 'components/product_list_section.dart';
import 'components/product_summery_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          children: [
            const DashBoardHeader(),
            const Gap(defaultPadding),
            _buildHeroStrip(context),
            const Gap(defaultPadding),
            ResponsiveUtils.isMobile(context)
                ? _buildMobileLayout(context)
                : _buildDesktopLayout(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStrip(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF142B57), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Snapshot',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 14 : null,
                ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'Fast actions for products, orders, and catalog updates.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                  fontSize: isMobile ? 12.5 : null,
                ),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _DashboardChip(label: 'Touch friendly'),
                _DashboardChip(label: 'Responsive tables'),
                _DashboardChip(label: 'Role based access'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _ActionBar(
          title: 'My Products',
          onAdd: () => showAddProductForm(context, null),
          compact: true,
        ),
        const Gap(defaultPadding),
        const ProductSummerySection(),
        const Gap(defaultPadding),
        const ProductListSection(),
        const Gap(defaultPadding),
        const OrderDetailsSection(),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _ActionBar(
                title: 'My Products',
                onAdd: () => showAddProductForm(context, null),
              ),
              const Gap(defaultPadding),
              const ProductSummerySection(),
              const Gap(defaultPadding),
              const ProductListSection(),
            ],
          ),
        ),
        const SizedBox(width: defaultPadding),
        const Expanded(flex: 2, child: OrderDetailsSection()),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.title,
    required this.onAdd,
    this.onRefresh,
    this.compact = false,
  });

  final String title;
  final VoidCallback onAdd;
  final VoidCallback? onRefresh;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAdd,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                    if (onRefresh != null) ...[
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.sync),
                      ),
                    ],
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
                if (onRefresh != null) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.sync),
                  ),
                ],
              ],
            ),
    );
  }
}

class _DashboardChip extends StatelessWidget {
  const _DashboardChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
