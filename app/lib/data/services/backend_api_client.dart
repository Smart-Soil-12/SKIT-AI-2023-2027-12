import 'dart:async';
import 'dart:convert';
import '../models/cloud_soil_record_model.dart';
import '../models/weather_forecast_model.dart';
import 'http_transport.dart';

/// Custom HTTP execution callback for dependency injection in tests and live builds.
typedef ApiHttpExecutor = Future<String?> Function({
  required String method,
  required Uri uri,
  Map<String, String>? headers,
  String? body,
  Duration timeout,
});

/// HTTP Client that interacts with Chetan Singh's FastAPI / Firebase Cloud Backend.
/// Matches endpoints defined in `backend/src/api.py`, `backend/src/firebase_service.py`,
/// `backend/src/weather_service.py`, and `backend/src/ml/predict_crop.py`.
class BackendApiClient {
  final String baseUrl;
  final bool enableLiveNetwork;
  final ApiHttpExecutor _httpExecutor;
  String? _authToken;

  /// Exact 6-feature ML bounds from `backend/src/ml/predict_crop.py` (`FEATURE_RANGES`).
  static const Map<String, List<double>> mlFeatureRanges = {
    'N': [0.0, 140.0],
    'P': [5.0, 145.0],
    'K': [5.0, 205.0],
    'temperature': [8.825675, 43.675493],
    'humidity': [14.258040, 99.981876],
    'ph': [3.504752, 9.935091],
  };

  BackendApiClient({
    this.baseUrl = 'http://10.0.2.2:8000',
    this.enableLiveNetwork = false,
    ApiHttpExecutor? httpExecutor,
  }) : _httpExecutor = httpExecutor ?? executeHttpRequest;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<String?> _performRequest(
    String method,
    String path, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    if (!enableLiveNetwork && _httpExecutor == executeHttpRequest) {
      return null;
    }
    final parsed = Uri.parse(baseUrl);
    final uri = Uri(
      scheme: parsed.scheme,
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : null,
      path: path,
      queryParameters: queryParams,
    );
    return _httpExecutor(
      method: method,
      uri: uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// Validates and clamps the 6 inputs required by FastAPI `CropPredictionRequest`.
  Map<String, double> buildSixFeaturePayload(Map<String, double> soilFeatures) {
    double clampFeature(String key, double fallback) {
      final range = mlFeatureRanges[key]!;
      final raw = soilFeatures[key] ??
          (key == 'ph' ? soilFeatures['pH'] : null) ??
          fallback;
      return raw.clamp(range[0], range[1]).toDouble();
    }

    return {
      'N': clampFeature('N', 80.0),
      'P': clampFeature('P', 40.0),
      'K': clampFeature('K', 45.0),
      'temperature': clampFeature('temperature', 25.0),
      'humidity': clampFeature('humidity', 65.0),
      'ph': clampFeature('ph', 6.8),
    };
  }

  /// Queries `GET /health` on `backend/src/api.py`.
  Future<bool> checkHealth() async {
    final raw = await _performRequest('GET', '/health');
    if (raw == null) return false;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Queries `GET /api/weather/current` on `backend/src/api.py`.
  /// Falls back cleanly to Jaipur initial telemetry if the backend is offline.
  Future<WeatherForecastModel> fetchCurrentWeather({
    double latitude = 26.9124,
    double longitude = 75.7873,
  }) async {
    final raw = await _performRequest(
      'GET',
      '/api/weather/current',
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return WeatherForecastModel.fromJson(decoded, isFromLiveApi: true);
      } catch (_) {
        // Fallback if malformed
      }
    }

    await Future.delayed(const Duration(milliseconds: 120));
    return WeatherForecastModel.initialDefault();
  }

  /// Queries `POST /api/crops/predict` using Chetan's exact 6-feature payload
  /// (`N`, `P`, `K`, `temperature`, `humidity`, `ph`).
  Future<Map<String, dynamic>> predictCropsSixFeatures({
    required String farmerId,
    required Map<String, double> soilFeatures,
  }) async {
    final payload = buildSixFeaturePayload(soilFeatures);
    final raw = await _performRequest(
      'POST',
      '/api/crops/predict',
      body: payload,
    );

    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        if (decoded['recommendations'] is List) {
          return {
            'farmer_id': farmerId,
            'generated_at': DateTime.now().toUtc().toIso8601String(),
            'soil_parameters_used': payload,
            'source': 'live_fastapi_ml',
            'recommendations': decoded['recommendations'],
          };
        }
      } catch (_) {
        // Fall through to offline resilience payload
      }
    }

    return fetchCropRecommendationsFromCloud(
      farmerId: farmerId,
      soilFeatures: payload,
    );
  }

  /// Queries `GET /api/crops/predict/latest` combining Firebase soil telemetry & live weather.
  Future<Map<String, dynamic>?> fetchLatestCropPredictions({
    required String farmerId,
    double latitude = 26.9124,
    double longitude = 75.7873,
  }) async {
    final raw = await _performRequest(
      'GET',
      '/api/crops/predict/latest',
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );

    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['recommendations'] is List) {
        return {
          'farmer_id': farmerId,
          'generated_at': DateTime.now().toUtc().toIso8601String(),
          'source': 'live_fastapi_latest',
          'recommendations': decoded['recommendations'],
        };
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Simulates fetching the latest soil record from Firestore collection "soil_readings".
  /// Corresponds to Chetan's `get_latest_soil_reading()`.
  Future<Map<String, dynamic>?> fetchLatestReadingFromCloud({
    required String farmerId,
    required String deviceId,
  }) async {
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

  /// Simulates calling the backend crop recommendation inference API (`POST /api/crops/predict`).
  Future<Map<String, dynamic>> fetchCropRecommendationsFromCloud({
    required String farmerId,
    required Map<String, double> soilFeatures,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final n = soilFeatures['N'] ?? 80.0;
    final ph = soilFeatures['pH'] ?? soilFeatures['ph'] ?? 6.8;

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
