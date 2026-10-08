import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/data/repositories/crop_recommendation_repository.dart';
import 'package:smart_soil/data/repositories/soil_telemetry_repository.dart';
import 'package:smart_soil/data/services/backend_api_client.dart';
import 'package:smart_soil/ui/dashboard/view_models/crop_recommendation_view_model.dart';

void main() {
  group('Sprint 4 / 5: CropRecommendationViewModel Unit Tests', () {
    late BackendApiClient apiClient;
    late SoilTelemetryRepository telemetryRepo;
    late CropRecommendationRepository cropRepo;
    late CropRecommendationViewModel viewModel;

    setUp(() {
      apiClient = BackendApiClient();
      telemetryRepo = SoilTelemetryRepository(apiClient: apiClient);
      cropRepo = CropRecommendationRepository(
        telemetryRepository: telemetryRepo,
        apiClient: apiClient,
      );
      viewModel = CropRecommendationViewModel(repository: cropRepo);
    });

    tearDown(() {
      telemetryRepo.dispose();
      viewModel.dispose();
    });

    test('initial state has no result and is not loading', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.result, isNull);
      expect(viewModel.top3Crops, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('loadRecommendations populates result and top3Crops', () async {
      await viewModel.loadRecommendations('farmer_chaitanya_01');

      expect(viewModel.isLoading, false);
      expect(viewModel.result, isNotNull);
      expect(viewModel.top3Crops.isNotEmpty, true);
      expect(viewModel.top3Crops.length <= 3, true);

      final topCrop = viewModel.top3Crops.first;
      expect(topCrop.cropName.isNotEmpty, true);
      expect(topCrop.suitabilityScore > 0, true);
    });

    test('simulateScenario updates result with custom soil telemetry', () async {
      final customFeatures = {
        'N': 110.0,
        'P': 55.0,
        'K': 190.0,
        'pH': 6.8,
      };

      await viewModel.simulateScenario('farmer_sim', customFeatures);

      expect(viewModel.isLoading, false);
      expect(viewModel.result, isNotNull);
      expect(viewModel.result?.farmerId, 'farmer_sim');
      expect(viewModel.top3Crops.isNotEmpty, true);
    });
  });
}
