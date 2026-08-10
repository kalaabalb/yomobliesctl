import '../../../utility/extensions.dart';
import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../utility/constants.dart';
import '../../../widgets/custom_text_field.dart';

class SendNotificationForm extends StatelessWidget {
  const SendNotificationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: context.notificationProvider.sendNotificationFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(ResponsiveUtils.getPadding(context)),
            CustomTextField(
              controller: context.notificationProvider.titleCtrl,
              labelText: 'Enter Notification Title ....',
              onSave: (val) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a Title name';
                }
                return null;
              },
            ),
            Gap(8),
            CustomTextField(
              controller: context.notificationProvider.descriptionCtrl,
              labelText: 'Enter Notification Description ....',
              lineNumber: 3,
              onSave: (val) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description ';
                }
                return null;
              },
            ),
            Gap(8),
            CustomTextField(
              controller: context.notificationProvider.imageUrlCtrl,
              labelText: 'Enter Notification Image Url ....',
              onSave: (val) {},
            ),
            Gap(ResponsiveUtils.getPadding(context) * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: secondaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: ResponsiveUtils.getPadding(context)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                  ),
                  onPressed: () {
                    if (context.notificationProvider.sendNotificationFormKey
                        .currentState!
                        .validate()) {
                      context.notificationProvider.sendNotificationFormKey
                          .currentState!
                          .save();
                      // TODO: should complete call sendNotification
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void sendNotificationFormForm(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Send Notification',
        child: SendNotificationForm(),
      );
    },
  );
}
