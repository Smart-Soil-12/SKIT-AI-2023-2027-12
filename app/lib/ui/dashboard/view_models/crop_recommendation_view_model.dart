import 'package:flutter/foundation.dart';
import '../../../data/models/crop_recommendation_model.dart';
import '../../../data/repositories/crop_recommendation_repository.dart';

/// ViewModel managing state for Top-3 Crop Recommendation display
/// Fulfills Form-2 Sprint 4 / Sprint 5 Task:
/// "Prepare Flutter response structure for top-3 crop & verified output fields for API integration & recommendation display."
class CropRecommendationViewModel extends ChangeNotifier {
  final CropRecommendationRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  CropRecommendationResult? _result;

  CropRecommendationViewModel({required this.repository}) {
    final initialSoil = repository.telemetryRepository
        .computeAggregatedSoilProfile('farmer_chaitanya_01');
    _result = CropRecommendationResult(
      farmerId: 'farmer_chaitanya_01',
      generatedAt: DateTime.now(),
      soilParametersUsed: initialSoil,
      recommendations: repository.rankCropsLocally(initialSoil, 3),
    );
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CropRecommendationResult? get result => _result;
  List<CropRecommendationItem> get top3Crops =>
      _result?.recommendations.take(3).toList() ?? const [];

  /// Loads crop recommendations using the farmer's aggregated soil telemetry
  /// and optional live weather inputs for the 6-feature ML prediction endpoint.
  Future<void> loadRecommendations(
    String farmerId, {
    double? temperature,
    double? humidity,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await repository.getRecommendationsForFarmer(
        farmerId,
        topK: 3,
        temperature: temperature,
        humidity: humidity,
      );
      _result = res;
    } catch (e) {
      _errorMessage = 'Failed to load recommendations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Queries Chetan's `GET /api/crops/predict/latest` (combined live Firebase
  /// soil telemetry + live weather) and enriches results via the 22-crop catalog.
  Future<void> refreshFromLatestCloud(String farmerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final latestJson =
          await repository.apiClient.fetchLatestCropPredictions(farmerId: farmerId);
      if (latestJson != null) {
        final parsed = CropRecommendationResult.fromJson(latestJson);
        _result = CropRecommendationResult(
          farmerId: parsed.farmerId,
          generatedAt: parsed.generatedAt,
          soilParametersUsed: repository.telemetryRepository
              .computeAggregatedSoilProfile(farmerId),
          recommendations: parsed.recommendations
              .take(3)
              .map(repository.enrichWithKnowledgeBase)
              .toList(),
        );
        return;
      }
      _result = await repository.getRecommendationsForFarmer(farmerId, topK: 3);
    } catch (e) {
      _errorMessage = 'Failed to sync latest cloud predictions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Manually recalculates recommendation based on what-if soil parameter scenarios.
  Future<void> simulateScenario(
    String farmerId,
    Map<String, double> soilFeatures,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await repository.apiClient.predictCropsSixFeatures(
        farmerId: farmerId,
        soilFeatures: soilFeatures,
      );
      final parsed = CropRecommendationResult.fromJson(res);
      _result = CropRecommendationResult(
        farmerId: parsed.farmerId,
        generatedAt: parsed.generatedAt,
        soilParametersUsed: parsed.soilParametersUsed,
        recommendations: parsed.recommendations
            .take(3)
            .map(repository.enrichWithKnowledgeBase)
            .toList(),
      );
    } catch (e) {
      _errorMessage = 'Simulation failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
