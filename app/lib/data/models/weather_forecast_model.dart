/// Weather Forecast & Agricultural Risk Model for Smart Soil.
/// Matches Chetan Singh's FastAPI `/api/weather/current` JSON schema
/// (`backend/src/weather_service.py`).
enum WeatherRiskLevel {
  low,
  moderate,
  high,
}

class WeatherForecastModel {
  final double temperature;
  final double humidity;
  final double rainfall;
  final String rainfallPeriod;
  final String time;
  final String locationName;
  final double windSpeedKmh;
  final double feelsLikeC;
  final bool isFromLiveApi;

  const WeatherForecastModel({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.rainfallPeriod,
    required this.time,
    this.locationName = 'Jaipur, Rajasthan',
    this.windSpeedKmh = 11.9,
    double? feelsLikeC,
    this.isFromLiveApi = false,
  }) : feelsLikeC = feelsLikeC ?? (temperature + 2.4);

  /// Default initial snapshot before live `/api/weather/current` sync completes.
  factory WeatherForecastModel.initialDefault() {
    return const WeatherForecastModel(
      temperature: 23.4,
      humidity: 91.0,
      rainfall: 0.52,
      rainfallPeriod: '16-day forecast (mm)',
      time: '2026-11-12',
      locationName: 'Jaipur, Rajasthan',
      windSpeedKmh: 11.9,
      feelsLikeC: 25.8,
      isFromLiveApi: false,
    );
  }

  /// Derives agronomic weather risk level from live meteorological telemetry.
  WeatherRiskLevel get riskLevel {
    if (humidity >= 85.0 || rainfall >= 60.0 || temperature >= 38.0) {
      return WeatherRiskLevel.high;
    }
    if (humidity >= 72.0 || rainfall <= 5.0 || temperature <= 12.0) {
      return WeatherRiskLevel.moderate;
    }
    return WeatherRiskLevel.low;
  }

  /// Human-readable condition summary based on live metrics.
  String get conditionSummary {
    if (rainfall >= 20.0) return 'Heavy rain forecast';
    if (humidity >= 85.0 && rainfall > 0.1) return 'Light rain shower';
    if (temperature >= 35.0) return 'Warm & sunny';
    return 'Partly cloudy';
  }

  factory WeatherForecastModel.fromJson(
    Map<String, dynamic> json, {
    String locationName = 'Jaipur, Rajasthan',
    bool isFromLiveApi = true,
  }) {
    final temp = (json['temperature'] as num?)?.toDouble() ?? 25.0;
    final hum = (json['humidity'] as num?)?.toDouble() ?? 60.0;
    final rain = (json['rainfall'] as num?)?.toDouble() ?? 0.0;

    return WeatherForecastModel(
      temperature: temp,
      humidity: hum,
      rainfall: rain,
      rainfallPeriod:
          json['rainfall_period'] as String? ?? '16-day forecast (mm)',
      time: json['time'] as String? ?? DateTime.now().toIso8601String().split('T').first,
      locationName: json['location_name'] as String? ?? locationName,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 11.9,
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble(),
      isFromLiveApi: isFromLiveApi,
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        'rainfall': rainfall,
        'rainfall_period': rainfallPeriod,
        'time': time,
        'location_name': locationName,
        'wind_speed_kmh': windSpeedKmh,
        'feels_like_c': feelsLikeC,
      };
}
