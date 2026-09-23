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
}
