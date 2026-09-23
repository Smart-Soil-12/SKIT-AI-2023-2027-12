import 'dart:async';
import '../models/cloud_soil_record_model.dart';
import '../models/soil_reading_model.dart';
import '../services/backend_api_client.dart';

/// Repository that abstracts Firestore "soil_readings" collection and local caching.
/// Fulfills Sprint 3 Week 2 requirements: Multi-tenant farmer isolation & historical records.
class SoilTelemetryRepository {
  final BackendApiClient apiClient;
  final StreamController<CloudSoilRecordModel> _telemetryStreamController =
      StreamController<CloudSoilRecordModel>.broadcast();

  final List<CloudSoilRecordModel> _cachedHistory = [];
  CloudSoilRecordModel? _lastKnownRecord;

  SoilTelemetryRepository({required this.apiClient}) {
    // Seed initial historical record matching Chetan's dataset
    final initial = CloudSoilRecordModel(
      id: 'init_record_001',
      farmerId: 'farmer_chaitanya_01',
      deviceId: 'ESP32_AI12_NODE_01',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isSimulated: true,
      reading: const SoilReadingModel(
        ph: 6.8,
        moisture: 58.0,
        nitrogen: 85.0,
        phosphorus: 38.0,
        potassium: 180.0,
        temperature: 25.5,
        humidity: 64.0,
      ),
    );
    _lastKnownRecord = initial;
    _cachedHistory.add(initial);
  }

  Stream<CloudSoilRecordModel> get telemetryStream => _telemetryStreamController.stream;
  CloudSoilRecordModel? get lastKnownRecord => _lastKnownRecord;
  List<CloudSoilRecordModel> get cachedHistory => List.unmodifiable(_cachedHistory);

  /// Retrieves the latest record from Chetan's Firestore collection.
  Future<CloudSoilRecordModel?> getLatestReading({
    required String farmerId,
    required String deviceId,
  }) async {
    try {
      final json = await apiClient.fetchLatestReadingFromCloud(
        farmerId: farmerId,
        deviceId: deviceId,
      );
      if (json != null) {
        final record = CloudSoilRecordModel.fromFirestore(json, json['id'] as String);
        _lastKnownRecord = record;
        _cachedHistory.insert(0, record);
        _telemetryStreamController.add(record);
        return record;
      }
    } catch (_) {
      // Return cached record if network query fails
    }
    return _lastKnownRecord;
  }

  /// Pushes a new reading into the pipeline and updates local stream.
  Future<bool> saveReading(CloudSoilRecordModel record) async {
    try {
      await apiClient.postSoilReadingToCloud(record);
      _lastKnownRecord = record;
      _cachedHistory.insert(0, record);
      _telemetryStreamController.add(record);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetches historical readings filtered by farmerId (tenant isolation).
  List<CloudSoilRecordModel> getFarmerHistory(String farmerId) {
    return _cachedHistory.where((r) => r.farmerId == farmerId).toList();
  }

  void dispose() {
    _telemetryStreamController.close();
  }
}
