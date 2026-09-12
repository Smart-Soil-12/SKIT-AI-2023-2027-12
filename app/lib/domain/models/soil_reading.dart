import '../../core/constants/soil_thresholds.dart';
import '../../core/utils/soil_validator.dart';
import 'soil_metric_status.dart';

/// Clean domain entity representing a set of soil & environmental measurements.
class SoilReading {
  final double? ph;
  final double? moisture;
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;
  final double? temperature;
  final double? humidity;

  const SoilReading({
    this.ph,
    this.moisture,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.temperature,
    this.humidity,
  });

  /// True if all essential parameters are present and within valid physical ranges.
  bool get isComplete =>
      ph != null &&
      moisture != null &&
      nitrogen != null &&
      phosphorus != null &&
      potassium != null &&
      temperature != null &&
      humidity != null &&
      isValid;

  /// Validates that any provided parameter is within acceptable physical boundaries.
  bool get isValid =>
      (ph == null || SoilValidator.isValidPh(ph)) &&
      (moisture == null || SoilValidator.isValidMoisture(moisture)) &&
      (nitrogen == null || SoilValidator.isValidNitrogen(nitrogen)) &&
      (phosphorus == null || SoilValidator.isValidPhosphorus(phosphorus)) &&
      (potassium == null || SoilValidator.isValidPotassium(potassium)) &&
      (temperature == null || SoilValidator.isValidTemperature(temperature)) &&
      (humidity == null || SoilValidator.isValidHumidity(humidity));

  // --- Status Evaluations ---
  SoilMetricStatus get phStatus => SoilValidator.evaluatePhStatus(ph);
  SoilMetricStatus get moistureStatus => SoilValidator.evaluateMoistureStatus(moisture);
  SoilMetricStatus get nitrogenStatus => SoilValidator.evaluateNitrogenStatus(nitrogen);
  SoilMetricStatus get phosphorusStatus => SoilValidator.evaluatePhosphorusStatus(phosphorus);
  SoilMetricStatus get potassiumStatus => SoilValidator.evaluatePotassiumStatus(potassium);
  SoilMetricStatus get temperatureStatus => SoilValidator.evaluateTemperatureStatus(temperature);
  SoilMetricStatus get humidityStatus => SoilValidator.evaluateHumidityStatus(humidity);

  // --- Formatted Value Helpers ---
  String get formattedPh => ph != null ? '${ph!.toStringAsFixed(1)} ${SoilThresholds.unitPh}' : '--';
  String get formattedMoisture => moisture != null ? '${moisture!.toStringAsFixed(1)} ${SoilThresholds.unitMoisture}' : '--';
  String get formattedNitrogen => nitrogen != null ? '${nitrogen!.toStringAsFixed(0)} ${SoilThresholds.unitNitrogen}' : '--';
  String get formattedPhosphorus => phosphorus != null ? '${phosphorus!.toStringAsFixed(0)} ${SoilThresholds.unitPhosphorus}' : '--';
  String get formattedPotassium => potassium != null ? '${potassium!.toStringAsFixed(0)} ${SoilThresholds.unitPotassium}' : '--';
  String get formattedTemperature => temperature != null ? '${temperature!.toStringAsFixed(1)} ${SoilThresholds.unitTemperature}' : '--';
  String get formattedHumidity => humidity != null ? '${humidity!.toStringAsFixed(1)} ${SoilThresholds.unitHumidity}' : '--';

  /// Computes a composite health index (0 - 100) indicating optimal soil status.
  int get healthScore {
    final statuses = [
      phStatus,
      moistureStatus,
      nitrogenStatus,
      phosphorusStatus,
      potassiumStatus,
      temperatureStatus,
      humidityStatus,
    ];

    int score = 0;
    for (final status in statuses) {
      if (status == SoilMetricStatus.optimal) {
        score += 100;
      } else if (status == SoilMetricStatus.low || status == SoilMetricStatus.high) {
        score += 60;
      } else if (status == SoilMetricStatus.criticalLow || status == SoilMetricStatus.criticalHigh) {
        score += 20;
      }
    }
    return (score / statuses.length).round();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoilReading &&
          runtimeType == other.runtimeType &&
          ph == other.ph &&
          moisture == other.moisture &&
          nitrogen == other.nitrogen &&
          phosphorus == other.phosphorus &&
          potassium == other.potassium &&
          temperature == other.temperature &&
          humidity == other.humidity;

  @override
  int get hashCode =>
      ph.hashCode ^
      moisture.hashCode ^
      nitrogen.hashCode ^
      phosphorus.hashCode ^
      potassium.hashCode ^
      temperature.hashCode ^
      humidity.hashCode;
}
