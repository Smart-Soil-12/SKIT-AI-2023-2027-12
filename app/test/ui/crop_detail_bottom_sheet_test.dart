import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/data/models/crop_recommendation_model.dart';
import 'package:smart_soil/ui/dashboard/widgets/crop_detail_bottom_sheet.dart';

void main() {
  group('Sprint 5 Week 2: CropDetailBottomSheet Tests', () {
    const testCrop = CropRecommendationItem(
      cropName: 'Wheat',
      suitabilityScore: 0.94,
      season: 'Rabi',
      confidenceLevel: 'High',
      agronomicHighlights: [
        'Optimal temperature between 18°C and 24°C during grain filling.',
        'Requires well-drained fertile loamy soil with balanced NPK.',
      ],
      optimalConditions: CropOptimalConditions(
        minN: 80,
        maxN: 110,
        minP: 40,
        maxP: 60,
        minK: 40,
        maxK: 60,
        minPh: 6.2,
        maxPh: 7.5,
        minTemp: 18,
        maxTemp: 24,
        minHumidity: 50,
        maxHumidity: 70,
        minRainfall: 75,
        maxRainfall: 125,
      ),
    );

    testWidgets('renders crop title, bilingual text, and nutrient status rows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CropDetailBottomSheet(
              crop: testCrop,
              currentSoil: {
                'N': 85.0,
                'P': 42.0,
                'K': 50.0,
                'pH': 6.8,
                'moisture': 55.0,
              },
            ),
          ),
        ),
      );

      // Verify header with Hindi and English
      expect(find.text('गेहूँ (Wheat)'), findsOneWidget);
      expect(find.text('Season: Rabi • Suitability: High'), findsOneWidget);
      expect(find.text('94% Match'), findsOneWidget);

      // Verify nutrient section
      expect(find.text('Soil Nutrient Status vs Crop Requirement'), findsOneWidget);
      expect(find.text('Nitrogen (N)'), findsOneWidget);
      expect(find.text('Phosphorus (P)'), findsOneWidget);
      expect(find.text('Potassium (K)'), findsOneWidget);
      expect(find.text('Soil Reaction (pH)'), findsOneWidget);
      expect(find.text('Root Moisture'), findsOneWidget);

      // Verify optimal statuses
      expect(find.text('Optimal (संतुलित)'), findsWidgets);

      // Verify fertilizer advice section
      expect(find.text('Recommended Soil Amendment & Fertilizer'), findsOneWidget);
      expect(find.textContaining('Nitrogen Status: Well-balanced'), findsOneWidget);

      // Verify button
      expect(find.text('Back to Dashboard / वापस जाएं'), findsOneWidget);
    });

    testWidgets('generates targeted fertilizer advice for nitrogen deficit and acidic pH', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CropDetailBottomSheet(
              crop: testCrop,
              currentSoil: {
                'N': 45.0, // Deficit (< 80)
                'P': 25.0, // Deficit (< 40)
                'K': 30.0, // Deficit (< 40)
                'pH': 5.4, // Acidic (< 6.2)
                'moisture': 35.0,
              },
            ),
          ),
        ),
      );

      // Verify deficit statuses appear
      expect(find.text('Deficit (कमी)'), findsWidgets);

      // Verify fertilizer recommendations are triggered
      expect(find.textContaining('Nitrogen Deficit'), findsOneWidget);
      expect(find.textContaining('Urea (46% N)'), findsOneWidget);
      expect(find.textContaining('Phosphorus Deficit'), findsOneWidget);
      expect(find.textContaining('Single Super Phosphate'), findsOneWidget);
      expect(find.textContaining('Potassium Deficit'), findsOneWidget);
      expect(find.textContaining('Muriate of Potash'), findsOneWidget);
      expect(find.textContaining('Acidic Soil Reaction'), findsOneWidget);
      expect(find.textContaining('agricultural lime'), findsOneWidget);
    });
  });
}
