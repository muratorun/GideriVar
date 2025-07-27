// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:giderivar/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GideriVarApp());

    // Verify that app name is displayed
    expect(find.text('Giderivar'), findsOneWidget);
    expect(find.text('Paylaş, Geri Dönüştür, Sürdürülebilir Yaşa'), findsOneWidget);
  });
}
