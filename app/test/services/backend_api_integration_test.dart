import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/data/models/crop_recommendation_model.dart';
import 'package:smart_soil/data/models/weather_forecast_model.dart';
import 'package:smart_soil/data/repositories/crop_recommendation_repository.dart';
import 'package:smart_soil/data/repositories/soil_telemetry_repository.dart';
import 'package:smart_soil/data/services/backend_api_client.dart';

void main() {
  group('Sprint 6: Live FastAPI & Weather Endpoint Alignment Tests', () {
    test('WeatherForecastModel parses /api/weather/current schema & derives risk', () {
      final highRiskWeather = WeatherForecastModel.fromJson({
        'temperature': 24.5,
        'humidity': 88.0,
        'rainfall': 12.4,
        'rainfall_period': '16-day forecast (mm)',
        'time': '2026-11-12',
      });

      expect(highRiskWeather.temperature, 24.5);
      expect(highRiskWeather.humidity, 88.0);
      expect(highRiskWeather.rainfall, 12.4);
      expect(highRiskWeather.rainfallPeriod, '16-day forecast (mm)');
      expect(highRiskWeather.riskLevel, WeatherRiskLevel.high);

      final lowRiskWeather = WeatherForecastModel.fromJson({
        'temperature': 26.0,
        'humidity': 58.0,
        'rainfall': 22.0,
        'rainfall_period': '16-day forecast (mm)',
        'time': '2026-11-12',
      });
      expect(lowRiskWeather.riskLevel, WeatherRiskLevel.low);
    });

    test('BackendApiClient.buildSixFeaturePayload enforces exact predict_crop.py ranges', () {
      final client = BackendApiClient();
      final payload = client.buildSixFeaturePayload({
        'N': 200.0, // > max 140
        'P': 1.0, // < min 5
        'K': 90.0,
        'temperature': 50.0, // > max 43.675493
        'humidity': 10.0, // < min 14.258040
        'pH': 6.7,
      });

      expect(payload.keys.toSet(), {'N', 'P', 'K', 'temperature', 'humidity', 'ph'});
      expect(payload['N'], 140.0);
      expect(payload['P'], 5.0);
      expect(payload['K'], 90.0);
      expect(payload['temperature'], closeTo(43.675493, 0.0001));
      expect(payload['humidity'], closeTo(14.258040, 0.0001));
      expect(payload['ph'], 6.7);
    });

    test('BackendApiClient connects cleanly to /health, /api/weather/current, and /api/crops/predict', () async {
      final calledEndpoints = <String>[];
      final mockClient = BackendApiClient(
        enableLiveNetwork: true,
        httpExecutor: ({
          required String method,
          required Uri uri,
          Map<String, String>? headers,
          String? body,
          Duration timeout = const Duration(seconds: 4),
        }) async {
          calledEndpoints.add('$method ${uri.path}');
          if (uri.path == '/health') {
            return jsonEncode({'status': 'ok', 'service': 'SmartSoil AI API'});
          }
          if (uri.path == '/api/weather/current') {
            return jsonEncode({
              'temperature': 27.8,
              'humidity': 55.0,
              'rainfall': 18.5,
              'rainfall_period': '16-day forecast (mm)',
              'time': '2026-11-12',
            });
          }
          if (uri.path == '/api/crops/predict') {
            return jsonEncode({
              'recommendations': [
                {'crop': 'rice', 'confidence': 87.5},
                {'crop': 'jute', 'confidence': 9.2},
                {'crop': 'maize', 'confidence': 3.3},
              ],
            });
          }
          return null;
        },
      );

      expect(await mockClient.checkHealth(), isTrue);

      final weather = await mockClient.fetchCurrentWeather();
      expect(weather.isFromLiveApi, isTrue);
      expect(weather.temperature, 27.8);
      expect(weather.riskLevel, WeatherRiskLevel.low);

      final telemetryRepo = SoilTelemetryRepository(apiClient: mockClient);
      final cropRepo = CropRecommendationRepository(
        telemetryRepository: telemetryRepo,
        apiClient: mockClient,
      );

      final recs = await cropRepo.getRecommendationsForFarmer(
        'farmer_chaitanya_01',
        temperature: weather.temperature,
        humidity: weather.humidity,
      );

      expect(recs.recommendations.length, 3);
      expect(recs.recommendations.first.cropName, 'Rice');
      expect(recs.recommendations.first.suitabilityPercentage, 88);
      // Enriched from 22-crop knowledge base
      expect(recs.recommendations.first.season, 'Kharif');
      expect(recs.recommendations.first.agronomicHighlights, isNotEmpty);
      expect(calledEndpoints, containsAll([
        'GET /health',
        'GET /api/weather/current',
        'POST /api/crops/predict',
      ]));

      telemetryRepo.dispose();
    });

    test('CropRecommendationItem.fromJson handles both FastAPI and legacy keys', () {
      final fastApiItem = CropRecommendationItem.fromJson({
        'crop': 'chickpea',
        'confidence': 92.4,
      });
      expect(fastApiItem.cropName, 'Chickpea');
      expect(fastApiItem.suitabilityPercentage, 92);
      expect(fastApiItem.confidenceLevel, 'High');
    });
  });
}
