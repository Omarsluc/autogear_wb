import 'package:auto_gear_wb/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Auto Gear app loads catalog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AutoGearApp());
    await tester.pump();

    expect(find.text('AUTO GEAR'), findsOneWidget);
    expect(find.text('Apply Filters'), findsOneWidget);
  });
}
