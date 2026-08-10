import '../../../models/my_notification.dart';
import '../provider/notification_provider.dart';
import '../../../utility/constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'notification_statics_card.dart';
import 'package:admin_panal_start/utility/responsive_utils.dart';
import 'package:admin_panal_start/widgets/compact_form_dialog.dart';

class ViewNotificationForm extends StatelessWidget {
  final MyNotification? notification;

  const ViewNotificationForm({Key? key, this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(notification?.title ?? 'N/A',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          Gap(10),
          Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                int totalSend =
                    notificationProvider.notificationResult?.successDelivery ??
                        0;
                int totalOpened = notificationProvider
                        .notificationResult?.openedNotification ??
                    0;
                int totalFailed =
                    notificationProvider.notificationResult?.failedDelivery ??
                        0;
                int totalError =
                    notificationProvider.notificationResult?.erroredDelivery ??
                        0;
                double calculatePercentage(int notificationCount) {
                  if (totalSend == 0) {
                    return 0;
                  } else {
                    return (notificationCount / totalSend) * 100;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationCard(
                      text: 'Total Send',
                      color: Colors.blue,
                      number: totalSend,
                      percentage: calculatePercentage(totalSend),
                    ),
                    Gap(8),
                    NotificationCard(
                      text: 'Total Opened',
                      color: Colors.green,
                      number: totalOpened,
                      percentage: calculatePercentage(totalOpened),
                    ),
                    Gap(8),
                    NotificationCard(
                      text: 'Total Failed',
                      color: Colors.red,
                      number: totalFailed,
                      percentage: calculatePercentage(totalFailed),
                    ),
                    Gap(8),
                    NotificationCard(
                      text: 'Total Error',
                      color: Colors.yellow,
                      number: totalError,
                      percentage: calculatePercentage(totalError),
                    ),
                  ],
                );
              },
            ),
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: secondaryColor),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

void viewNotificationStatics(
    BuildContext context, MyNotification? notification) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Notification Statics',
        child: ViewNotificationForm(notification: notification),
      );
    },
  );
}
