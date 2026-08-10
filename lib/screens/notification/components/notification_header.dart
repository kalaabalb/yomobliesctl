import 'package:flutter/material.dart';
import '../../../widgets/responsive_header.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveHeader(
      title: "Notification",
      onSearch: (val) {
        // TODO: Implement notification search when needed
      },
    );
  }
}
