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
    final initialSoil = repository.telemetryRepository.computeAggregatedSoilProfile('farmer_chaitanya_01');
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

  /// Loads crop recommendations using the farmer's aggregated soil telemetry.
  Future<void> loadRecommendations(String farmerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await repository.getRecommendationsForFarmer(farmerId, topK: 3);
      _result = res;
    } catch (e) {
      _errorMessage = 'Failed to load recommendations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Manually recalculates recommendation based on what-if soil parameter scenarios.
  Future<void> simulateScenario(String farmerId, Map<String, double> soilFeatures) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await repository.apiClient.fetchCropRecommendationsFromCloud(
        farmerId: farmerId,
        soilFeatures: soilFeatures,
      );
      _result = CropRecommendationResult.fromJson(res);
    } catch (e) {
      _errorMessage = 'Simulation failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
