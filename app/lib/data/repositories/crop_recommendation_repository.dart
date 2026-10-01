import 'dart:math' as math;
import '../models/crop_recommendation_model.dart';
import '../services/backend_api_client.dart';
import 'soil_telemetry_repository.dart';

/// Repository that handles agronomic crop recommendation inference and caching.
/// Fulfills Form-1 Objective 3 ("train ML model for prediction of top 3 crops") and
/// Form-2 Sprint 4 Task ("Prepare Flutter structures to receive & display crop recommendation").
class CropRecommendationRepository {
  final SoilTelemetryRepository telemetryRepository;
  final BackendApiClient apiClient;

  CropRecommendationResult? _cachedRecommendation;

  CropRecommendationRepository({
    required this.telemetryRepository,
    required this.apiClient,
  });

  CropRecommendationResult? get cachedRecommendation => _cachedRecommendation;

  /// Knowledge base of reference crop parameters from backend/data/Crop_recommendation.csv
  static const List<Map<String, dynamic>> _referenceCrops = [
    {
      'name': 'Rice',
      'season': 'Kharif',
      'opt_N': 80.0,
      'opt_P': 48.0,
      'opt_K': 40.0,
      'opt_ph': 6.5,
      'opt_temp': 24.0,
      'opt_humidity': 82.0,
      'opt_rainfall': 236.0,
      'highlights': [
        'High water and moisture retention capacity recommended.',
        'Thrives in slightly acidic to neutral loam soil.',
      ],
    },
    {
      'name': 'Wheat',
      'season': 'Rabi',
      'opt_N': 85.0,
      'opt_P': 42.0,
      'opt_K': 45.0,
      'opt_ph': 6.8,
      'opt_temp': 20.0,
      'opt_humidity': 60.0,
      'opt_rainfall': 100.0,
      'highlights': [
        'Optimal temperature between 18°C and 24°C during grain filling.',
        'Requires well-drained fertile loamy soil with balanced NPK.',
      ],
    },
    {
      'name': 'Maize',
      'season': 'Kharif',
      'opt_N': 78.0,
      'opt_P': 48.0,
      'opt_K': 20.0,
      'opt_ph': 6.5,
      'opt_temp': 23.0,
      'opt_humidity': 65.0,
      'opt_rainfall': 85.0,
      'highlights': [
        'High phosphorus utilization for root elongation.',
        'Deep rooted crop, resilient to moderate temperature variations.',
      ],
    },
    {
      'name': 'Chickpea',
      'season': 'Rabi',
      'opt_N': 40.0,
      'opt_P': 68.0,
      'opt_K': 80.0,
      'opt_ph': 7.2,
      'opt_temp': 19.0,
      'opt_humidity': 17.0,
      'opt_rainfall': 80.0,
      'highlights': [
        'Nitrogen-fixing legume, restores depleted soil fertility.',
        'Requires low relative humidity and moderate residual moisture.',
      ],
    },
    {
      'name': 'Cotton',
      'season': 'Kharif',
      'opt_N': 118.0,
      'opt_P': 46.0,
      'opt_K': 20.0,
      'opt_ph': 6.9,
      'opt_temp': 24.0,
      'opt_humidity': 80.0,
      'opt_rainfall': 80.0,
      'highlights': [
        'High nitrogen demand for vegetative and boll formation.',
        'Black cotton soil with high clay and moisture retention is ideal.',
      ],
    },
  ];

  /// Generates top crop recommendations using the farmer's historical aggregated soil readings.
  Future<CropRecommendationResult> getRecommendationsForFarmer(
    String farmerId, {
    int topK = 3,
  }) async {
    // 1. Compute statistical average soil parameters across farmer's history
    final soilProfile = telemetryRepository.computeAggregatedSoilProfile(farmerId);

    try {
      // 2. Query cloud inference API if available
      final cloudJson = await apiClient.fetchCropRecommendationsFromCloud(
        farmerId: farmerId,
        soilFeatures: soilProfile,
      );
      final result = CropRecommendationResult.fromJson(cloudJson);
      _cachedRecommendation = result;
      return result;
    } catch (_) {
      // 3. Fallback to offline multi-parameter scoring engine
      final ranked = _rankCropsLocally(soilProfile, topK);
      final result = CropRecommendationResult(
        farmerId: farmerId,
        generatedAt: DateTime.now(),
        soilParametersUsed: soilProfile,
        recommendations: ranked,
      );
      _cachedRecommendation = result;
      return result;
    }
  }

  /// Offline agronomic scoring algorithm based on Normalized Euclidean Proximity.
  List<CropRecommendationItem> _rankCropsLocally(
    Map<String, double> soil,
    int topK,
  ) {
    final n = soil['N'] ?? 80.0;
    final p = soil['P'] ?? 40.0;
    final k = soil['K'] ?? 150.0;
    final ph = soil['pH'] ?? 6.8;

    final scoredList = <MapEntry<double, Map<String, dynamic>>>[];

    for (final crop in _referenceCrops) {
      final optN = crop['opt_N'] as double;
      final optP = crop['opt_P'] as double;
      final optK = crop['opt_K'] as double;
      final optPh = crop['opt_ph'] as double;

      // Normalized Euclidean distance
      final distN = math.pow((n - optN) / 100.0, 2);
      final distP = math.pow((p - optP) / 50.0, 2);
      final distK = math.pow((k - optK) / 100.0, 2);
      final distPh = math.pow((ph - optPh) / 2.0, 2);

      final totalDist = math.sqrt(distN + distP + distK + distPh);
      // Convert distance to normalized suitability percentage
      final score = (1.0 / (1.0 + totalDist)).clamp(0.40, 0.98);

      scoredList.add(MapEntry(score, crop));
    }

    scoredList.sort((a, b) => b.key.compareTo(a.key));

    return scoredList.take(topK).map((entry) {
      final score = entry.key;
      final crop = entry.value;
      return CropRecommendationItem(
        cropName: crop['name'] as String,
        suitabilityScore: double.parse(score.toStringAsFixed(2)),
        season: crop['season'] as String,
        confidenceLevel: score >= 0.85 ? 'High' : 'Moderate',
        agronomicHighlights: List<String>.from(crop['highlights'] as List),
        optimalConditions: CropOptimalConditions(
          minN: (crop['opt_N'] as double) * 0.8,
          maxN: (crop['opt_N'] as double) * 1.2,
          minP: (crop['opt_P'] as double) * 0.8,
          maxP: (crop['opt_P'] as double) * 1.2,
          minK: (crop['opt_K'] as double) * 0.8,
          maxK: (crop['opt_K'] as double) * 1.2,
          minPh: (crop['opt_ph'] as double) - 0.5,
          maxPh: (crop['opt_ph'] as double) + 0.5,
          minTemp: 18.0,
          maxTemp: 32.0,
          minHumidity: 40.0,
          maxHumidity: 85.0,
          minRainfall: 60.0,
          maxRainfall: 200.0,
        ),
      );
    }).toList();
  }
}
