import 'package:flutter_test/flutter_test.dart';

import 'package:admin_panal_start/main.dart';

void main() {
  testWidgets('admin app boots to the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Marketplace Admin'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
