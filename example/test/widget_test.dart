// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:animated_notch_topbar_example/main.dart';
import 'package:animated_notch_topbar/animated_notch_topbar.dart';

void main() {
  testWidgets('ExampleApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('Hi, Dilshad 👋'), findsOneWidget);
    expect(find.byType(AnimatedNotchTopBar), findsOneWidget);
  });
}
