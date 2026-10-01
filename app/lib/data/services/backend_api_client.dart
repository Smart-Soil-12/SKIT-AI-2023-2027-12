import 'dart:async';
import '../models/cloud_soil_record_model.dart';

/// HTTP Client that interacts with Chetan Singh's FastAPI / Firebase Cloud Backend.
/// Matches endpoints defined in backend/src/firebase_service.py and backend/src/firebase_auth.py.
class BackendApiClient {
  final String baseUrl;
  String? _authToken;

  BackendApiClient({this.baseUrl = 'http://10.0.2.2:8000'});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Simulates fetching the latest soil record from Firestore collection "soil_readings".
  /// Corresponds to Chetan's `get_latest_soil_reading()`.
  Future<Map<String, dynamic>?> fetchLatestReadingFromCloud({
    required String farmerId,
    required String deviceId,
  }) async {
    // In live network mode: http.get(Uri.parse('$baseUrl/api/soil/latest?farmer_id=$farmerId&device_id=$deviceId'))
    // Returns simulated standard payload matching backend/src/firebase_service.py
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': 'doc_${DateTime.now().millisecondsSinceEpoch}',
      'farmer_id': farmerId,
      'device_id': deviceId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'pH': 6.8,
      'moisture': 58.5,
      'N': 88.0,
      'P': 36.5,
      'K': 175.0,
      'temperature': 25.2,
      'humidity': 64.0,
      'is_simulated': false,
    };
  }

  /// Simulates posting a validated telemetry record to Chetan's `save_soil_reading()`.
  Future<String> postSoilReadingToCloud(CloudSoilRecordModel record) async {
    await Future.delayed(const Duration(milliseconds: 350));
    // Payload matching Chetan's backend/src/firebase_service.py: save_soil_reading()
    final payload = {
      'farmer_id': record.farmerId,
      'device_id': record.deviceId,
      'timestamp': record.timestamp.toIso8601String(),
      'pH': record.reading.ph,
      'moisture': record.reading.moisture,
      'N': record.reading.nitrogen,
      'P': record.reading.phosphorus,
      'K': record.reading.potassium,
      'temperature': record.reading.temperature,
    };
    return 'doc_${DateTime.now().millisecondsSinceEpoch}_${payload["farmer_id"]}';
  }

  /// Simulates fetching structured historical soil readings for an authenticated farmer.
  /// Corresponds to Chetan's `get_farmer_soil_readings(farmer_id)`.
  Future<List<Map<String, dynamic>>> fetchFarmerHistoricalReadingsFromCloud({
    required String farmerId,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now().toUtc();
    return [
      {
        'id': 'hist_${farmerId}_01',
        'farmer_id': farmerId,
        'device_id': 'ESP32_AI12_NODE_01',
        'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'pH': 6.8,
        'moisture': 58.0,
        'N': 85.0,
        'P': 38.0,
        'K': 180.0,
        'temperature': 25.5,
        'humidity': 64.0,
      },
      {
        'id': 'hist_${farmerId}_02',
        'farmer_id': farmerId,
        'device_id': 'ESP32_AI12_NODE_01',
        'timestamp': now.subtract(const Duration(hours: 6)).toIso8601String(),
        'pH': 6.7,
        'moisture': 54.0,
        'N': 82.0,
        'P': 37.0,
        'K': 178.0,
        'temperature': 26.2,
        'humidity': 62.0,
      },
      {
        'id': 'hist_${farmerId}_03',
        'farmer_id': farmerId,
        'device_id': 'ESP32_AI12_NODE_01',
        'timestamp': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'pH': 6.9,
        'moisture': 61.0,
        'N': 87.0,
        'P': 39.0,
        'K': 182.0,
        'temperature': 24.8,
        'humidity': 66.0,
      },
    ].take(limit).toList();
  }

  /// Simulates calling the backend crop recommendation inference API.
  Future<Map<String, dynamic>> fetchCropRecommendationsFromCloud({
    required String farmerId,
    required Map<String, double> soilFeatures,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final n = soilFeatures['N'] ?? 80.0;
    final ph = soilFeatures['pH'] ?? 6.8;

    return {
      'farmer_id': farmerId,
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'soil_parameters_used': soilFeatures,
      'recommendations': [
        {
          'crop_name': ph >= 6.5 && n >= 70 ? 'Wheat' : 'Rice',
          'suitability_score': 0.94,
          'season': 'Rabi',
          'confidence_level': 'High',
          'agronomic_highlights': [
            'Optimal soil pH balance for root nutrition.',
            'Balanced NPK ratio supports vigorous tillering.',
          ],
        },
        {
          'crop_name': 'Maize',
          'suitability_score': 0.86,
          'season': 'Kharif',
          'confidence_level': 'High',
          'agronomic_highlights': [
            'Good nitrogen buffer in current field profile.',
          ],
        },
        {
          'crop_name': 'Chickpea',
          'suitability_score': 0.78,
          'season': 'Rabi',
          'confidence_level': 'Moderate',
          'agronomic_highlights': [
            'Leguminous crop suitable for soil nitrogen fixation.',
          ],
        },
      ],
    };
  }
}

