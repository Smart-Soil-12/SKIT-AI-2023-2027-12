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

  /// Fetches historical time-series readings from Chetan's cloud collection for an authenticated farmer.
  Future<List<CloudSoilRecordModel>> fetchHistoricalTimeSeries(
    String farmerId, {
    int limit = 10,
  }) async {
    try {
      final recordsJson = await apiClient.fetchFarmerHistoricalReadingsFromCloud(
        farmerId: farmerId,
        limit: limit,
      );
      final fetched = recordsJson
          .map((j) => CloudSoilRecordModel.fromFirestore(j, j['id'] as String))
          .toList();
      for (final r in fetched) {
        if (!_cachedHistory.any((c) => c.id == r.id)) {
          _cachedHistory.add(r);
        }
      }
      return getFarmerHistory(farmerId);
    } catch (_) {
      return getFarmerHistory(farmerId);
    }
  }

  /// Calculates statistical averages across the farmer's historical telemetry records.
  /// Eliminates sensor spikes and noisy single-sample variations before crop recommendation.
  Map<String, double> computeAggregatedSoilProfile(String farmerId) {
    final history = getFarmerHistory(farmerId);
    if (history.isEmpty) {
      final fallback = _lastKnownRecord?.reading ??
          const SoilReadingModel(
            ph: 6.8,
            moisture: 50.0,
            nitrogen: 80.0,
            phosphorus: 40.0,
            potassium: 150.0,
            temperature: 25.0,
            humidity: 60.0,
          );
      return {
        'pH': fallback.ph ?? 6.8,
        'moisture': fallback.moisture ?? 50.0,
        'N': fallback.nitrogen ?? 80.0,
        'P': fallback.phosphorus ?? 40.0,
        'K': fallback.potassium ?? 150.0,
        'temperature': fallback.temperature ?? 25.0,
        'humidity': fallback.humidity ?? 60.0,
      };
    }

    double totalPh = 0;
    double totalMoisture = 0;
    double totalN = 0;
    double totalP = 0;
    double totalK = 0;
    double totalTemp = 0;
    double totalHumidity = 0;

    for (final record in history) {
      totalPh += record.reading.ph ?? 6.8;
      totalMoisture += record.reading.moisture ?? 50.0;
      totalN += record.reading.nitrogen ?? 80.0;
      totalP += record.reading.phosphorus ?? 40.0;
      totalK += record.reading.potassium ?? 150.0;
      totalTemp += record.reading.temperature ?? 25.0;
      totalHumidity += record.reading.humidity ?? 60.0;
    }

    final count = history.length.toDouble();
    return {
      'pH': double.parse((totalPh / count).toStringAsFixed(2)),
      'moisture': double.parse((totalMoisture / count).toStringAsFixed(2)),
      'N': double.parse((totalN / count).toStringAsFixed(2)),
      'P': double.parse((totalP / count).toStringAsFixed(2)),
      'K': double.parse((totalK / count).toStringAsFixed(2)),
      'temperature': double.parse((totalTemp / count).toStringAsFixed(2)),
      'humidity': double.parse((totalHumidity / count).toStringAsFixed(2)),
    };
  }

  /// Identifies critical nutrient deficiencies based on historical aggregated soil telemetry.
  List<String> getSoilHealthDeficiencies(String farmerId) {
    final profile = computeAggregatedSoilProfile(farmerId);
    final deficiencies = <String>[];

    final n = profile['N'] ?? 80.0;
    final p = profile['P'] ?? 40.0;
    final k = profile['K'] ?? 150.0;
    final ph = profile['pH'] ?? 6.8;

    if (n < 50.0) deficiencies.add('Critical Nitrogen Deficiency (< 50 kg/ha)');
    if (p < 25.0) deficiencies.add('Low Phosphorus Reserve (< 25 kg/ha)');
    if (k < 100.0) deficiencies.add('Potassium Deficiency (< 100 kg/ha)');
    if (ph < 5.8) deficiencies.add('Acidic Soil Condition (pH < 5.8)');
    if (ph > 7.8) deficiencies.add('Alkaline Soil Condition (pH > 7.8)');

    return deficiencies;
  }

  void dispose() {
    _telemetryStreamController.close();
  }
}

