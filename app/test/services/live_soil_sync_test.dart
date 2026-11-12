import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/core/state/smart_soil_scope.dart';
import 'package:smart_soil/data/repositories/crop_recommendation_repository.dart';
import 'package:smart_soil/data/repositories/soil_telemetry_repository.dart';
import 'package:smart_soil/data/services/backend_api_client.dart';
import 'package:smart_soil/ui/dashboard/view_models/crop_recommendation_view_model.dart';
import 'package:smart_soil/ui/dashboard/widgets/soil_telemetry_trend_card.dart';
import 'package:smart_soil/ui/farm_soil/views/farm_soil_telemetry_screen.dart';

void main() {
  group('Sprint 7 Week 1: Live Soil Sync, Trend Pipeline & Cloud ML Refresh', () {
    test('SoilTelemetryRepository.fetchHistoricalTimeSeries + buildTrendSeries produces 7-point chronological series', () async {
      final repo = SoilTelemetryRepository(apiClient: BackendApiClient());

      final records = await repo.fetchHistoricalTimeSeries('farmer_chaitanya_01');
      expect(records.length, greaterThanOrEqualTo(3));

      final chronological = List.of(records)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final trend = repo.buildTrendSeries('farmer_chaitanya_01', points: 7);
      expect(
        trend.keys.toSet(),
        {'Moisture', 'pH', 'Nitrogen', 'Phosphorus', 'Potassium'},
      );
      for (final entry in trend.entries) {
        expect(entry.value.length, 7, reason: '${entry.key} should have 7 points');
      }
      // Latest chronological cloud reading values sit at the end of the 7-point window
      expect(trend['Moisture']!.last, chronological.last.reading.moisture);
      expect(trend['pH']!.last, chronological.last.reading.ph);
      expect(trend['Nitrogen']!.last, chronological.last.reading.nitrogen);
    });

    test('CropRecommendationViewModel.refreshFromLatestCloud queries /api/crops/predict/latest and falls back cleanly', () async {
      final requestedPaths = <String>[];
      final liveClient = BackendApiClient(
        enableLiveNetwork: true,
        httpExecutor: ({
          required String method,
          required Uri uri,
          Map<String, String>? headers,
          String? body,
          Duration timeout = const Duration(seconds: 4),
        }) async {
          requestedPaths.add('$method ${uri.path}');
          if (uri.path == '/api/crops/predict/latest') {
            return jsonEncode({
              'recommendations': [
                {'crop_name': 'papaya', 'suitability_score': 0.912},
                {'crop_name': 'banana', 'suitability_score': 0.064},
                {'crop_name': 'mango', 'suitability_score': 0.024},
              ],
            });
          }
          return null;
        },
      );

      final liveTelemetryRepo = SoilTelemetryRepository(apiClient: liveClient);
      final liveRepo = CropRecommendationRepository(
        telemetryRepository: liveTelemetryRepo,
        apiClient: liveClient,
      );
      final liveVm = CropRecommendationViewModel(repository: liveRepo);
      await liveVm.refreshFromLatestCloud('farmer_chaitanya_01');

      expect(requestedPaths, contains('GET /api/crops/predict/latest'));
      expect(liveVm.top3Crops, isNotEmpty);
      expect(liveVm.top3Crops.first.cropName.toLowerCase(), contains('papaya'));
      expect(liveVm.errorMessage, isNull);

      // Offline / null response should gracefully fall back to local/soil-feature recommendations
      final offlineClient = BackendApiClient(enableLiveNetwork: false);
      final offlineTelemetryRepo = SoilTelemetryRepository(apiClient: offlineClient);
      final offlineRepo = CropRecommendationRepository(
        telemetryRepository: offlineTelemetryRepo,
        apiClient: offlineClient,
      );
      final offlineVm = CropRecommendationViewModel(repository: offlineRepo);
      await offlineVm.refreshFromLatestCloud('farmer_chaitanya_01');

      expect(offlineVm.top3Crops, isNotEmpty);
      expect(offlineVm.errorMessage, isNull);
    });

    testWidgets('SmartSoilScope injects telemetryRepo and FarmSoilTelemetryScreen cloud sync updates metrics, trends & crops', (
      WidgetTester tester,
    ) async {
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
          if (uri.path == '/api/crops/predict/latest') {
            return jsonEncode({
              'recommendations': [
                {'crop': 'chickpea', 'confidence': 88.4},
                {'crop': 'lentil', 'confidence': 7.6},
                {'crop': 'maize', 'confidence': 4.0},
              ],
            });
          }
          return null;
        },
      );

      await tester.pumpWidget(
        SmartSoilAppState(
          apiClientOverride: mockClient,
          child: const MaterialApp(
            home: Scaffold(
              body: FarmSoilTelemetryScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scope = SmartSoilScope.of(
        tester.element(find.byType(FarmSoilTelemetryScreen)),
      );

      // Tap cloud sync button to trigger dashboard refreshData, historical fetch, and /api/crops/predict/latest
      final syncButton = find.byIcon(Icons.cloud_sync_rounded);
      expect(syncButton, findsOneWidget);
      await tester.tap(syncButton);
      await tester.pumpAndSettle();

      // Verify DashboardViewModel has live telemetryRepo injected & updated reading from cloud
      expect(scope.dashboard.reading.moisture, 58.5);
      expect(scope.dashboard.reading.ph, 6.8);
      expect(scope.dashboard.reading.nitrogen, 88.0);

      // Verify historical trend pipeline populated SoilTelemetryTrendCard
      final trendCard = tester.widget<SoilTelemetryTrendCard>(
        find.byType(SoilTelemetryTrendCard),
      );
      expect(trendCard.historicalData, isNotNull);
      expect(trendCard.historicalData!['Moisture']?.length, 7);

      // Verify /api/crops/predict/latest updated CropRecommendationViewModel
      expect(calledEndpoints, contains('GET /api/crops/predict/latest'));
      expect(
        scope.cropVm.top3Crops.first.cropName.toLowerCase(),
        contains('chickpea'),
      );
    });
  });
}
