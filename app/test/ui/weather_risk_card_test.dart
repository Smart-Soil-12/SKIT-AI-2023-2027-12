import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/core/state/smart_soil_scope.dart';
import 'package:smart_soil/data/services/backend_api_client.dart';
import 'package:smart_soil/ui/home/widgets/weather_risk_card.dart';

void main() {
  testWidgets('WeatherRiskCard updates reactively from live /api/weather/current API', (
    WidgetTester tester,
  ) async {
    final mockClient = BackendApiClient(
      enableLiveNetwork: true,
      httpExecutor: ({
        required String method,
        required Uri uri,
        Map<String, String>? headers,
        String? body,
        Duration timeout = const Duration(seconds: 4),
      }) async {
        if (uri.path == '/health') {
          return jsonEncode({'status': 'ok', 'service': 'SmartSoil AI API'});
        }
        if (uri.path == '/api/weather/current') {
          return jsonEncode({
            'temperature': 26.2,
            'humidity': 55.0,
            'rainfall': 14.0,
            'rainfall_period': '16-day forecast (mm)',
            'time': '2026-11-12',
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
            body: SingleChildScrollView(child: WeatherRiskCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial offline default before refresh
    expect(find.text('23.4°C'), findsOneWidget);
    expect(find.text('Offline Sync'), findsOneWidget);

    // Tap refresh button to pull from live mocked FastAPI
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    // Verify dynamic live values & Live FastAPI status badge
    expect(find.text('26.2°C'), findsOneWidget);
    expect(find.text('55%'), findsOneWidget);
    expect(find.text('14.00 mm'), findsOneWidget);
    expect(find.text('Low Risk'), findsWidgets);
    expect(find.text('Live FastAPI'), findsOneWidget);

    // Switch locale to Hindi and check translation
    final scope = SmartSoilScope.of(tester.element(find.byType(WeatherRiskCard)));
    scope.language.setLocale('hi');
    await tester.pumpAndSettle();

    expect(find.text('लाइव FastAPI'), findsOneWidget);
    expect(find.text('कम जोखिम'), findsOneWidget);
  });
}
