import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_soil/core/state/smart_soil_scope.dart';
import 'package:smart_soil/ui/main_navigation_scaffold.dart';

Widget createTestApp() {
  return const SmartSoilAppState(
    child: MaterialApp(
      home: MainNavigationScaffold(),
    ),
  );
}

void main() {
  testWidgets('Smart Soil 5-tab navigation and home screen renders correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    // Verify user greeting & Smart Soil branding
    expect(find.textContaining('Hello, Chaitanya Sharma'), findsOneWidget);
    expect(find.text('Welcome to Smart Soil'), findsOneWidget);

    // Verify Hero Crop Scanner Card
    expect(find.text('Scan Your Crop'), findsOneWidget);
    expect(find.text('Open Camera'), findsOneWidget);

    // Verify Weather & Risk Card
    expect(find.text('23.4°C'), findsOneWidget);
    expect(find.textContaining('Advisory: High humidity'), findsOneWidget);

    // Verify Farmers News
    expect(find.text('Farmers News', skipOffstage: false), findsOneWidget);

    // Tap Scan tab via icon
    await tester.tap(find.byIcon(Icons.camera_alt_outlined));
    await tester.pumpAndSettle();
    expect(find.text('AI Crop Disease Scanner'), findsOneWidget);
    expect(find.text('AI Diagnosis Result'), findsOneWidget);

    // Tap Yield tab via icon
    await tester.tap(find.byIcon(Icons.trending_up_rounded));
    await tester.pumpAndSettle();
    expect(find.text('AI Crop Yield Prediction'), findsOneWidget);

    // Tap Ask AI tab via icon
    await tester.tap(find.byIcon(Icons.smart_toy_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    // Tap Soil & Farm tab via icon
    await tester.tap(find.byIcon(Icons.eco_outlined));
    await tester.pumpAndSettle();
    expect(find.textContaining('ESP32_AI12_NODE_01'), findsAtLeastNWidgets(1));
  });

  testWidgets('Language toggling switches to Hindi strings properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    final scope = SmartSoilScope.of(tester.element(find.byType(MainNavigationScaffold)));
    scope.language.setLocale('hi');
    await tester.pumpAndSettle();

    expect(find.textContaining('नमस्ते, Chaitanya Sharma'), findsOneWidget);
    expect(find.text('स्मार्ट सॉइल में आपका स्वागत है'), findsOneWidget);
    expect(find.text('अपनी फसल स्कैन करें'), findsOneWidget);
    expect(find.text('कैमरा खोलें'), findsOneWidget);
    expect(find.text('किसान समाचार', skipOffstage: false), findsOneWidget);
  });
}
