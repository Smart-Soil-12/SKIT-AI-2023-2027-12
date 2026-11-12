import 'package:flutter/foundation.dart';
import '../../../data/models/weather_forecast_model.dart';
import '../../../data/services/backend_api_client.dart';

/// Reactive ViewModel managing live Open-Meteo / FastAPI meteorological data
/// and backend connection state for the Home Screen dashboard.
class WeatherViewModel extends ChangeNotifier {
  final BackendApiClient apiClient;

  WeatherForecastModel _forecast = WeatherForecastModel.initialDefault();
  bool _isLoading = false;
  bool _isBackendOnline = false;
  String? _errorMessage;

  WeatherViewModel({required this.apiClient});

  WeatherForecastModel get forecast => _forecast;
  bool get isLoading => _isLoading;
  bool get isBackendOnline => _isBackendOnline;
  String? get errorMessage => _errorMessage;

  /// Fetches live weather telemetry from FastAPI `/api/weather/current`
  /// and verifies backend health via `/health`.
  Future<void> loadWeather({
    double latitude = 26.9124,
    double longitude = 75.7873,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        apiClient.checkHealth(),
        apiClient.fetchCurrentWeather(
          latitude: latitude,
          longitude: longitude,
        ),
      ]);
      _isBackendOnline = results[0] as bool;
      _forecast = results[1] as WeatherForecastModel;
    } catch (e) {
      _errorMessage = 'Weather sync unavailable: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
