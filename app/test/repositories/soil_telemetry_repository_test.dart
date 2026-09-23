import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/data/models/cloud_soil_record_model.dart';
import 'package:smart_soil/data/models/soil_reading_model.dart';
import 'package:smart_soil/data/repositories/soil_telemetry_repository.dart';
import 'package:smart_soil/data/services/backend_api_client.dart';

void main() {
  group('Sprint 3 Week 2: SoilTelemetryRepository & Chetan Cloud Backend', () {
    late BackendApiClient apiClient;
    late SoilTelemetryRepository repository;

    setUp(() {
      apiClient = BackendApiClient();
      repository = SoilTelemetryRepository(apiClient: apiClient);
    });

    tearDown(() {
      repository.dispose();
    });

    test('initializes with seed historical record and lastKnownRecord', () {
      expect(repository.lastKnownRecord, isNotNull);
      expect(repository.lastKnownRecord?.farmerId, equals('farmer_chaitanya_01'));
      expect(repository.cachedHistory.isNotEmpty, isTrue);
    });

    test('fetches latest reading from Firestore and updates stream & cache', () async {
      final record = await repository.getLatestReading(
        farmerId: 'farmer_chaitanya_01',
        deviceId: 'ESP32_AI12_NODE_01',
      );

      expect(record, isNotNull);
      expect(record?.farmerId, equals('farmer_chaitanya_01'));
      expect(record?.deviceId, equals('ESP32_AI12_NODE_01'));
      expect(record?.reading.ph, equals(6.8));
      expect(repository.lastKnownRecord?.id, equals(record?.id));
    });

    test('saves new telemetry record and isolates records by farmer tenant', () async {
      final newRecord = CloudSoilRecordModel(
        id: 'rec_tenant_test_02',
        farmerId: 'farmer_aryan_02',
        deviceId: 'ESP32_NODE_02',
        timestamp: DateTime.now().toUtc(),
        isSimulated: false,
        reading: const SoilReadingModel(
          ph: 7.1,
          moisture: 60.0,
          nitrogen: 90.0,
          phosphorus: 40.0,
          potassium: 190.0,
          temperature: 26.0,
          humidity: 60.0,
        ),
      );

      final success = await repository.saveReading(newRecord);
      expect(success, isTrue);

      final chaitanyaRecords = repository.getFarmerHistory('farmer_chaitanya_01');
      final aryanRecords = repository.getFarmerHistory('farmer_aryan_02');

      expect(chaitanyaRecords.every((r) => r.farmerId == 'farmer_chaitanya_01'), isTrue);
      expect(aryanRecords.length, equals(1));
      expect(aryanRecords.first.deviceId, equals('ESP32_NODE_02'));
    });
  });
}
