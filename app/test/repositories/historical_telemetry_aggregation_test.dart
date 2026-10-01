import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/data/models/cloud_soil_record_model.dart';
import 'package:smart_soil/data/models/soil_reading_model.dart';
import 'package:smart_soil/data/repositories/crop_recommendation_repository.dart';
import 'package:smart_soil/data/repositories/soil_telemetry_repository.dart';
import 'package:smart_soil/data/services/backend_api_client.dart';

void main() {
  group('Sprint 3 Week 3: Historical Telemetry Aggregation & Crop Recommendation Repository', () {
    late BackendApiClient apiClient;
    late SoilTelemetryRepository repository;
    late CropRecommendationRepository cropRepo;

    setUp(() {
      apiClient = BackendApiClient();
      repository = SoilTelemetryRepository(apiClient: apiClient);
      cropRepo = CropRecommendationRepository(
        telemetryRepository: repository,
        apiClient: apiClient,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('fetchHistoricalTimeSeries retrieves multiple cloud readings and updates cache', () async {
      final records = await repository.fetchHistoricalTimeSeries(
        'farmer_chaitanya_01',
        limit: 5,
      );

      expect(records.isNotEmpty, true);
      expect(repository.cachedHistory.length >= records.length, true);

      // Verify tenant isolation
      final otherFarmer = repository.getFarmerHistory('farmer_other_99');
      expect(otherFarmer.isEmpty, true);
    });

    test('computeAggregatedSoilProfile calculates accurate statistical means over history', () async {
      const farmerId = 'farmer_test_agg';

      // Insert 2 controlled readings
      final record1 = CloudSoilRecordModel(
        id: 'rec_1',
        farmerId: farmerId,
        deviceId: 'ESP32_AI12_NODE_01',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        reading: const SoilReadingModel(
          ph: 6.0,
          moisture: 40.0,
          nitrogen: 60.0,
          phosphorus: 30.0,
          potassium: 100.0,
          temperature: 20.0,
          humidity: 50.0,
        ),
      );

      final record2 = CloudSoilRecordModel(
        id: 'rec_2',
        farmerId: farmerId,
        deviceId: 'ESP32_AI12_NODE_01',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        reading: const SoilReadingModel(
          ph: 7.0,
          moisture: 60.0,
          nitrogen: 100.0,
          phosphorus: 50.0,
          potassium: 200.0,
          temperature: 30.0,
          humidity: 70.0,
        ),
      );

      await repository.saveReading(record1);
      await repository.saveReading(record2);

      final profile = repository.computeAggregatedSoilProfile(farmerId);

      expect(profile['pH'], 6.5);
      expect(profile['moisture'], 50.0);
      expect(profile['N'], 80.0);
      expect(profile['P'], 40.0);
      expect(profile['K'], 150.0);
      expect(profile['temperature'], 25.0);
      expect(profile['humidity'], 60.0);
    });

    test('getSoilHealthDeficiencies identifies deficient nutrients', () async {
      const deficientFarmer = 'farmer_deficient';

      final deficientRecord = CloudSoilRecordModel(
        id: 'rec_def',
        farmerId: deficientFarmer,
        deviceId: 'ESP32_AI12_NODE_01',
        timestamp: DateTime.now(),
        reading: const SoilReadingModel(
          ph: 5.2, // Acidic
          moisture: 30.0,
          nitrogen: 35.0, // Low Nitrogen (< 50)
          phosphorus: 15.0, // Low Phosphorus (< 25)
          potassium: 75.0, // Low Potassium (< 100)
          temperature: 28.0,
          humidity: 45.0,
        ),
      );

      await repository.saveReading(deficientRecord);

      final deficiencies = repository.getSoilHealthDeficiencies(deficientFarmer);

      expect(deficiencies.length, 4);
      expect(deficiencies.any((d) => d.contains('Nitrogen Deficiency')), true);
      expect(deficiencies.any((d) => d.contains('Low Phosphorus')), true);
      expect(deficiencies.any((d) => d.contains('Potassium Deficiency')), true);
      expect(deficiencies.any((d) => d.contains('Acidic Soil Condition')), true);
    });

    test('CropRecommendationRepository produces top-3 ranked crops based on historical soil', () async {
      final result = await cropRepo.getRecommendationsForFarmer(
        'farmer_chaitanya_01',
        topK: 3,
      );

      expect(result.farmerId, 'farmer_chaitanya_01');
      expect(result.recommendations.isNotEmpty, true);
      expect(result.recommendations.length <= 3, true);

      final topCrop = result.topCrop;
      expect(topCrop, isNotNull);
      expect(topCrop!.suitabilityScore > 0.0, true);
      expect(topCrop.agronomicHighlights.isNotEmpty, true);
      expect(cropRepo.cachedRecommendation, isNotNull);
    });
  });
}
