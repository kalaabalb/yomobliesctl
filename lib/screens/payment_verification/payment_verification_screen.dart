import 'package:admin_panal_start/models/order.dart';
import 'package:admin_panal_start/utility/extensions.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../core/data/data_provider.dart';
import '../../utility/constants.dart';
import '../../widgets/responsive_header.dart';

class PaymentVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
        child: Column(
          children: [
            _buildHeader(),
            Gap(defaultPadding),
            _buildPendingVerificationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveHeader(
      title: "Payment Verification",
      onSearch: (val) {
        // Implement search if needed
      },
      actionButton: null,
    );
  }

  Widget _buildPendingVerificationSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pending Payment Verification",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.dataProvider.getAllOrders(showSnack: true);
                },
                icon: Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
          Gap(defaultPadding),
          Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              final pendingOrders = dataProvider.orders
                  .where((order) =>
                      order.paymentMethod != 'cod' &&
                      order.paymentStatus == 'pending' &&
                      order.paymentProof?.imageUrl != null)
                  .toList();

              if (pendingOrders.isEmpty) {
                return Center(
                  child: Text(
                    "No pending payment verifications",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pendingOrders.length,
                itemBuilder: (context, index) {
                  return _buildVerificationCard(context, pendingOrders[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(BuildContext context, Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: defaultPadding),
      color: Colors.grey[900],
      child: Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${_shortOrderId(order.sId)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Customer: ${order.userID?.name ?? 'N/A'}",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Amount: ETB ${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Payment Method: ${order.paymentMethod?.toUpperCase() ?? 'N/A'}",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildActionButton(
                      context,
                      "View Proof",
                      Icons.remove_red_eye,
                      Colors.blue,
                      () => _viewPaymentProof(context, order),
                    ),
                    Gap(8),
                    _buildActionButton(
                      context,
                      "Verify",
                      Icons.verified,
                      Colors.green,
                      () => _verifyPayment(context, order, true),
                    ),
                    Gap(8),
                    _buildActionButton(
                      context,
                      "Reject",
                      Icons.cancel,
                      Colors.red,
                      () => _verifyPayment(context, order, false),
                    ),
                  ],
                ),
              ],
            ),
            if (order.paymentProof?.uploadedAt != null) ...[
              Gap(8),
              Text(
                "Uploaded: ${_formatDate(order.paymentProof!.uploadedAt)}",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 120,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(text, style: TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }

  void _viewPaymentProof(BuildContext context, Order order) {
    if (order.paymentProof?.imageUrl != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Payment Proof",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(defaultPadding),
                Image.network(
                  order.paymentProof!.imageUrl!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[800],
                      child: Center(
                        child: Text(
                          "Failed to load image",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                Gap(defaultPadding),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Close"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _verifyPayment(BuildContext context, Order order, bool verified) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          verified ? "Verify Payment" : "Reject Payment",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          verified
              ? "Are you sure you want to verify this payment?"
              : "Are you sure you want to reject this payment?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.orderProvider.verifyPayment(order, verified);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: verified ? Colors.green : Colors.red,
            ),
            child: Text(verified ? "Verify" : "Reject"),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }

  String _shortOrderId(String? orderId) {
    if (orderId == null || orderId.isEmpty) return 'N/A';
    return orderId.length > 6 ? orderId.substring(orderId.length - 6) : orderId;
  }
}
