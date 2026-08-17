import 'package:flutter_test/flutter_test.dart';

import 'package:vag_dmp_frontend/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const VagDmpApp());
    // Verify the app renders the login screen title
    expect(find.text('VAG-DMP'), findsWidgets);
  });
}
