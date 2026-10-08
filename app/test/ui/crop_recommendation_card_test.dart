import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/data/models/crop_recommendation_model.dart';
import 'package:smart_soil/ui/dashboard/widgets/crop_recommendation_card.dart';

void main() {
  group('Sprint 4 / 5: CropRecommendationCard Widget Tests', () {
    late CropRecommendationResult testResult;

    setUp(() {
      testResult = CropRecommendationResult(
        farmerId: 'farmer_chaitanya_01',
        generatedAt: DateTime.now(),
        soilParametersUsed: {
          'N': 85.0,
          'P': 42.0,
          'K': 180.0,
          'pH': 6.8,
        },
        recommendations: const [
          CropRecommendationItem(
            cropName: 'Wheat',
            suitabilityScore: 0.94,
            season: 'Rabi',
            confidenceLevel: 'High',
            agronomicHighlights: ['Optimal soil pH balance for root nutrition.'],
            optimalConditions: CropOptimalConditions(
              minN: 70,
              maxN: 110,
              minP: 30,
              maxP: 50,
              minK: 35,
              maxK: 55,
              minPh: 6.0,
              maxPh: 7.5,
              minTemp: 15,
              maxTemp: 25,
              minHumidity: 40,
              maxHumidity: 70,
              minRainfall: 75,
              maxRainfall: 150,
            ),
          ),
          CropRecommendationItem(
            cropName: 'Maize',
            suitabilityScore: 0.86,
            season: 'Kharif',
            confidenceLevel: 'High',
            agronomicHighlights: ['Good nitrogen buffer in current field profile.'],
            optimalConditions: CropOptimalConditions(
              minN: 60,
              maxN: 90,
              minP: 35,
              maxP: 50,
              minK: 20,
              maxK: 40,
              minPh: 6.2,
              maxPh: 7.2,
              minTemp: 18,
              maxTemp: 28,
              minHumidity: 50,
              maxHumidity: 70,
              minRainfall: 60,
              maxRainfall: 120,
            ),
          ),
          CropRecommendationItem(
            cropName: 'Chickpea',
            suitabilityScore: 0.78,
            season: 'Rabi',
            confidenceLevel: 'Moderate',
            agronomicHighlights: ['Leguminous crop suitable for soil nitrogen fixation.'],
            optimalConditions: CropOptimalConditions(
              minN: 30,
              maxN: 50,
              minP: 50,
              maxP: 80,
              minK: 60,
              maxK: 90,
              minPh: 6.5,
              maxPh: 7.8,
              minTemp: 16,
              maxTemp: 24,
              minHumidity: 15,
              maxHumidity: 40,
              minRainfall: 60,
              maxRainfall: 100,
            ),
          ),
        ],
      );
    });

    testWidgets('renders top-3 crops with ranking badges and match percentages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CropRecommendationCard(
                recommendationResult: testResult,
              ),
            ),
          ),
        ),
      );

      // Verify header
      expect(find.text('Top Crop Recommendations'), findsOneWidget);
      expect(find.text('AI-Driven Field Suitability'), findsOneWidget);

      // Verify top-3 crops
      expect(find.text('Wheat'), findsOneWidget);
      expect(find.text('Maize'), findsOneWidget);
      expect(find.text('Chickpea'), findsOneWidget);

      // Verify rank badges
      expect(find.text('#1'), findsOneWidget);
      expect(find.text('#2'), findsOneWidget);
      expect(find.text('#3'), findsOneWidget);

      // Verify match percentage badges
      expect(find.text('94% Match'), findsOneWidget);
      expect(find.text('86% Match'), findsOneWidget);
      expect(find.text('78% Match'), findsOneWidget);

      // Verify soil baseline footer
      expect(find.textContaining('Soil Baseline: N:85 P:42 K:180 | pH:6.8'), findsOneWidget);
    });

    testWidgets('calls onRefresh when refresh button is tapped', (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CropRecommendationCard(
                recommendationResult: testResult,
                onRefresh: () => refreshed = true,
              ),
            ),
          ),
        ),
      );

      final refreshBtn = find.byIcon(Icons.refresh);
      expect(refreshBtn, findsOneWidget);

      await tester.tap(refreshBtn);
      await tester.pump();

      expect(refreshed, true);
    });
  });
}
