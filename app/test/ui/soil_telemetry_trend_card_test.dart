import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/ui/dashboard/widgets/soil_telemetry_trend_card.dart';

void main() {
  group('Sprint 6 Week 1: SoilTelemetryTrendCard Widget Tests', () {
    testWidgets('renders header, bilingual labels, and default moisture trend', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SoilTelemetryTrendCard(),
            ),
          ),
        ),
      );

      // Verify header and bilingual description
      expect(find.text('7-Day Soil Telemetry Trend'), findsOneWidget);
      expect(find.text('7-दिवसीय ऐतिहासिक मिट्टी रुझान विश्लेषण'), findsOneWidget);

      // Verify all 5 metric chips appear
      expect(find.text('Moisture'), findsOneWidget);
      expect(find.text('pH'), findsOneWidget);
      expect(find.text('Nitrogen'), findsOneWidget);
      expect(find.text('Phosphorus'), findsOneWidget);
      expect(find.text('Potassium'), findsOneWidget);

      // Verify statistics labels
      expect(find.text('7-Day Avg'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);

      // Verify default Moisture units
      expect(find.textContaining('%'), findsWidgets);

      // Verify day labels
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('D-1'), findsOneWidget);
      expect(find.text('D-6'), findsOneWidget);
    });

    testWidgets('switching metric chip updates statistics and active unit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SoilTelemetryTrendCard(),
            ),
          ),
        ),
      );

      // Tap on pH chip
      await tester.tap(find.text('pH'));
      await tester.pumpAndSettle();

      // Verify pH unit and footnote update
      expect(find.textContaining('pH'), findsWidgets);
      expect(find.textContaining('Reaction / पीएच'), findsOneWidget);

      // Tap on Nitrogen chip
      await tester.tap(find.text('Nitrogen'));
      await tester.pumpAndSettle();

      // Verify Nitrogen unit and footnote update
      expect(find.textContaining('mg/kg'), findsWidgets);
      expect(find.textContaining('Nitrogen (N) / नाइट्रोजन'), findsOneWidget);
    });

    testWidgets('renders custom telemetry series with calculated direction badge', (tester) async {
      const customHistory = {
        'Moisture': [30.0, 32.0, 35.0, 38.0, 42.0, 46.0, 52.0], // Rising (+22)
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SoilTelemetryTrendCard(
                historicalData: customHistory,
                initialMetric: 'Moisture',
              ),
            ),
          ),
        ),
      );

      // Verify trend direction badge
      expect(find.text('Rising'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);

      // Verify custom values
      expect(find.text('30'), findsOneWidget);
      expect(find.text('52'), findsOneWidget);
    });
  });
}
