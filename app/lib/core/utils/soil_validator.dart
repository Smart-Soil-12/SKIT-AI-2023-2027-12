import '../constants/soil_thresholds.dart';
import '../../domain/models/soil_metric_status.dart';

/// Utility class for validating, sanitizing, and evaluating soil metric measurements.
class SoilValidator {
  SoilValidator._();

  /// Safely parses dynamic values (int, double, numeric String) into a nullable double.
  static double? parseNumeric(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  // --- Field Range Validations ---

  /// Validates if pH is within physical scale [0.0, 14.0].
  static bool isValidPh(double? value) {
    if (value == null) return false;
    return value >= SoilThresholds.minPh && value <= SoilThresholds.maxPh;
  }

  /// Validates if Soil Moisture percentage is within [0.0, 100.0].
  static bool isValidMoisture(double? value) {
    if (value == null) return false;
    return value >= SoilThresholds.minMoisture && value <= SoilThresholds.maxMoisture;
  }

  /// Validates if Nitrogen level is within physical sensor range [0.0, 500.0].
  static bool isValidNitrogen(double? value) {
    if (value == null) return false;
    return value >= SoilThresholds.minNitrogen && value <= SoilThresholds.maxNitrogen;
  }

  /// Validates if Phosphorus level is within physical sensor range [0.0, 300.0].
  static bool isValidPhosphorus(double? value) {
    if (value == null) return false;
    return value >= SoilThresholds.minPhosphorus && value <= SoilThresholds.maxPhosphorus;
  }

  /// Validates if Potassium level is within physical sensor range [0.0, 600.0].
  static bool isValidPotassium(double? value) {
    if (value == null) return false;
    return value >= SoilThresholds.minPotassium && value <= SoilThresholds.maxPotassium;
  }

  /// Validates if Temperature is within viable sensor limits [-10.0, 60.0].
  static bool isValidTemperature(double? value) {
    if (value == null) return false;
    return value >= SoilThresholds.minTemperature && value <= SoilThresholds.maxTemperature;
  }

  /// Validates if Humidity percentage is within [0.0, 100.0].
  static bool isValidHumidity(double? value) {
    if (value == null) return false;
    return value >= SoilThresholds.minHumidity && value <= SoilThresholds.maxHumidity;
  }

  // --- Status Evaluation ---

  /// Evaluates the agronomic status of pH.
  static SoilMetricStatus evaluatePhStatus(double? ph) {
    if (ph == null || !isValidPh(ph)) return SoilMetricStatus.unknown;
    if (ph < SoilThresholds.phStronglyAcidic) return SoilMetricStatus.criticalLow;
    if (ph < SoilThresholds.phOptimalMin) return SoilMetricStatus.low;
    if (ph <= SoilThresholds.phOptimalMax) return SoilMetricStatus.optimal;
    if (ph <= SoilThresholds.phStronglyAlkaline) return SoilMetricStatus.high;
    return SoilMetricStatus.criticalHigh;
  }

  /// Evaluates the agronomic status of Moisture.
  static SoilMetricStatus evaluateMoistureStatus(double? moisture) {
    if (moisture == null || !isValidMoisture(moisture)) return SoilMetricStatus.unknown;
    if (moisture < SoilThresholds.moistureCriticalDry) return SoilMetricStatus.criticalLow;
    if (moisture < SoilThresholds.moistureOptimalMin) return SoilMetricStatus.low;
    if (moisture <= SoilThresholds.moistureOptimalMax) return SoilMetricStatus.optimal;
    if (moisture < SoilThresholds.moistureWaterlogged) return SoilMetricStatus.high;
    return SoilMetricStatus.criticalHigh;
  }

  /// Evaluates the status of Nitrogen (N).
  static SoilMetricStatus evaluateNitrogenStatus(double? n) {
    if (n == null || !isValidNitrogen(n)) return SoilMetricStatus.unknown;
    if (n < (SoilThresholds.nitrogenLow / 2)) return SoilMetricStatus.criticalLow;
    if (n < SoilThresholds.nitrogenLow) return SoilMetricStatus.low;
    if (n <= SoilThresholds.nitrogenOptimalMax) return SoilMetricStatus.optimal;
    if (n <= SoilThresholds.nitrogenExcess) return SoilMetricStatus.high;
    return SoilMetricStatus.criticalHigh;
  }

  /// Evaluates the status of Phosphorus (P).
  static SoilMetricStatus evaluatePhosphorusStatus(double? p) {
    if (p == null || !isValidPhosphorus(p)) return SoilMetricStatus.unknown;
    if (p < (SoilThresholds.phosphorusLow / 2)) return SoilMetricStatus.criticalLow;
    if (p < SoilThresholds.phosphorusLow) return SoilMetricStatus.low;
    if (p <= SoilThresholds.phosphorusOptimalMax) return SoilMetricStatus.optimal;
    if (p <= SoilThresholds.phosphorusExcess) return SoilMetricStatus.high;
    return SoilMetricStatus.criticalHigh;
  }

  /// Evaluates the status of Potassium (K).
  static SoilMetricStatus evaluatePotassiumStatus(double? k) {
    if (k == null || !isValidPotassium(k)) return SoilMetricStatus.unknown;
    if (k < (SoilThresholds.potassiumLow / 2)) return SoilMetricStatus.criticalLow;
    if (k < SoilThresholds.potassiumLow) return SoilMetricStatus.low;
    if (k <= SoilThresholds.potassiumOptimalMax) return SoilMetricStatus.optimal;
    if (k <= SoilThresholds.potassiumExcess) return SoilMetricStatus.high;
    return SoilMetricStatus.criticalHigh;
  }

  /// Evaluates the status of Temperature.
  static SoilMetricStatus evaluateTemperatureStatus(double? temp) {
    if (temp == null || !isValidTemperature(temp)) return SoilMetricStatus.unknown;
    if (temp <= SoilThresholds.tempFrostWarning) return SoilMetricStatus.criticalLow;
    if (temp < SoilThresholds.tempOptimalMin) return SoilMetricStatus.low;
    if (temp <= SoilThresholds.tempOptimalMax) return SoilMetricStatus.optimal;
    if (temp < SoilThresholds.tempHeatStress) return SoilMetricStatus.high;
    return SoilMetricStatus.criticalHigh;
  }

  /// Evaluates the status of Humidity.
  static SoilMetricStatus evaluateHumidityStatus(double? humidity) {
    if (humidity == null || !isValidHumidity(humidity)) return SoilMetricStatus.unknown;
    if (humidity < SoilThresholds.humidityLow) return SoilMetricStatus.low;
    if (humidity <= SoilThresholds.humidityOptimalMax) return SoilMetricStatus.optimal;
    if (humidity < SoilThresholds.humidityHigh) return SoilMetricStatus.high;
    return SoilMetricStatus.criticalHigh;
  }
}
