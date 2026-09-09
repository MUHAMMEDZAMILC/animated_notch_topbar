// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animated_notch_topbar_example/main.dart';
import 'package:animated_notch_topbar/animated_notch_topbar.dart';

void main() {
  testWidgets('ExampleApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('Hi, @master_zing_mz 👋'), findsOneWidget);
    expect(find.byType(AnimatedNotchTopBar), findsOneWidget);
  });

  testWidgets('tapping a coming-soon tab opens the poster bottom sheet',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    // The "%Off Zone" tab (index 2) renders its selected/unselected images
    // instead of text, so target it by tab position rather than by label.
    await tester.tap(find.byType(InkWell).at(2));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('%Off Zone is coming soon!'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Learn more'), findsOneWidget);
  });
}
