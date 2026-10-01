import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/data/models/crop_recommendation_model.dart';

void main() {
  group('Sprint 3 Week 3: CropRecommendationModel & Serialization', () {
    test('CropOptimalConditions serializes and parses properly', () {
      const conditions = CropOptimalConditions(
        minN: 60.0,
        maxN: 100.0,
        minP: 35.0,
        maxP: 55.0,
        minK: 35.0,
        maxK: 60.0,
        minPh: 6.2,
        maxPh: 7.2,
        minTemp: 18.0,
        maxTemp: 28.0,
        minHumidity: 50.0,
        maxHumidity: 75.0,
        minRainfall: 80.0,
        maxRainfall: 160.0,
      );

      final json = conditions.toJson();
      expect(json['min_N'], 60.0);
      expect(json['max_ph'], 7.2);

      final parsed = CropOptimalConditions.fromJson(json);
      expect(parsed.minN, 60.0);
      expect(parsed.maxPh, 7.2);
      expect(parsed.minRainfall, 80.0);
    });

    test('CropRecommendationItem parses full item payload and computes percentage', () {
      final itemJson = {
        'crop_name': 'Wheat',
        'suitability_score': 0.942,
        'season': 'Rabi',
        'confidence_level': 'High',
        'agronomic_highlights': [
          'Optimal soil pH balance for root nutrition.',
        ],
        'optimal_conditions': {
          'min_N': 70.0,
          'max_N': 110.0,
          'min_P': 30.0,
          'max_P': 50.0,
          'min_K': 35.0,
          'max_K': 55.0,
          'min_ph': 6.0,
          'max_ph': 7.5,
          'min_temp': 15.0,
          'max_temp': 25.0,
          'min_humidity': 40.0,
          'max_humidity': 70.0,
          'min_rainfall': 75.0,
          'max_rainfall': 150.0,
        },
      };

      final item = CropRecommendationItem.fromJson(itemJson);
      expect(item.cropName, 'Wheat');
      expect(item.suitabilityScore, 0.942);
      expect(item.suitabilityPercentage, 94);
      expect(item.season, 'Rabi');
      expect(item.confidenceLevel, 'High');
      expect(item.agronomicHighlights.length, 1);
    });

    test('CropRecommendationResult identifies top recommended crop', () {
      const topItem = CropRecommendationItem(
        cropName: 'Rice',
        suitabilityScore: 0.96,
        season: 'Kharif',
        confidenceLevel: 'High',
        agronomicHighlights: ['Clay loam soil recommended'],
        optimalConditions: CropOptimalConditions(
          minN: 80,
          maxN: 120,
          minP: 40,
          maxP: 60,
          minK: 40,
          maxK: 60,
          minPh: 6.0,
          maxPh: 7.0,
          minTemp: 22,
          maxTemp: 32,
          minHumidity: 70,
          maxHumidity: 90,
          minRainfall: 150,
          maxRainfall: 300,
        ),
      );

      const secondItem = CropRecommendationItem(
        cropName: 'Maize',
        suitabilityScore: 0.82,
        season: 'Kharif',
        confidenceLevel: 'Moderate',
        agronomicHighlights: ['Moderate nitrogen demand'],
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
      );

      final result = CropRecommendationResult(
        farmerId: 'farmer_chaitanya_01',
        generatedAt: DateTime.now(),
        soilParametersUsed: {'N': 85.0, 'P': 42.0, 'K': 180.0, 'pH': 6.8},
        recommendations: [topItem, secondItem],
      );

      expect(result.topCrop?.cropName, 'Rice');
      expect(result.recommendations.length, 2);

      final serialized = result.toJson();
      expect(serialized['farmer_id'], 'farmer_chaitanya_01');
      expect((serialized['recommendations'] as List).length, 2);

      final parsed = CropRecommendationResult.fromJson(serialized);
      expect(parsed.farmerId, 'farmer_chaitanya_01');
      expect(parsed.topCrop?.cropName, 'Rice');
    });
  });
}
