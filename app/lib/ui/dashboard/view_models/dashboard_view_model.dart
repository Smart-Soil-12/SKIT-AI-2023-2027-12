import 'package:flutter/material.dart';
import '../../../../smart_soil.dart';
import '../../core/app_theme.dart';
import '../../../data/repositories/soil_telemetry_repository.dart';
import '../../../core/services/hardware_bridge_service.dart';

/// Interactive state management for the Smart Soil Android Dashboard.
/// Links directly to Chetan Singh's SoilTelemetryRepository and Aryan's HardwareBridgeService.
class DashboardViewModel extends ChangeNotifier {
  SoilReading _reading;
  final String _farmerName = 'Chaitanya Sharma';
  final String _deviceId = 'ESP32_AI12_NODE_01';
  DateTime _lastUpdated = DateTime.now();
  final bool _isSimulated = true;
  bool _isLoading = false;
  String _currentScenario = 'Optimal Agronomic Soil';

  SoilTelemetryRepository? _telemetryRepo;
  HardwareBridgeService? _hardwareBridge;
  HardwareBridgeService? get hardwareBridge => _hardwareBridge;

  DashboardViewModel({
    SoilTelemetryRepository? telemetryRepo,
    HardwareBridgeService? hardwareBridge,
  })  : _telemetryRepo = telemetryRepo,
        _hardwareBridge = hardwareBridge,
        _reading = SoilReadingModel.fromJson(const {
          'ph': 6.8,
          'moisture': 55.0,
          'nitrogen': 95.0,
          'phosphorus': 38.0,
          'potassium': 185.0,
          'temperature': 24.5,
          'humidity': 62.0,
        });

  void attachServices({
    required SoilTelemetryRepository telemetryRepo,
    required HardwareBridgeService hardwareBridge,
  }) {
    _telemetryRepo = telemetryRepo;
    _hardwareBridge = hardwareBridge;
  }

  SoilReading get reading => _reading;
  String get farmerName => _farmerName;
  String get deviceId => _deviceId;
  DateTime get lastUpdated => _lastUpdated;
  bool get isSimulated => _isSimulated;
  bool get isLoading => _isLoading;
  String get currentScenario => _currentScenario;

  int get healthScore => _reading.healthScore;

  String get healthStatusLabel {
    if (healthScore >= 80) return 'Optimal Soil Health';
    if (healthScore >= 50) return 'Attention Recommended';
    return 'Critical Soil Intervention Required';
  }

  Color get healthStatusColor {
    if (healthScore >= 80) return AppTheme.statusOptimal;
    if (healthScore >= 50) return AppTheme.statusWarning;
    return AppTheme.statusCritical;
  }

  /// Dynamic agronomic advisory message computed from sensor parameters.
  String get advisoryMessage {
    if (_reading.moistureStatus == SoilMetricStatus.criticalLow) {
      return '⚠️ Urgent: Soil moisture at ${_reading.formattedMoisture}. Water stress detected. Initiate irrigation immediately.';
    }
    if (_reading.moistureStatus == SoilMetricStatus.criticalHigh) {
      return '⚠️ Warning: Waterlogged soil condition detected. Halt irrigation and verify field drainage.';
    }
    if (_reading.phStatus == SoilMetricStatus.criticalLow) {
      return '⚠️ Severe soil acidity detected (${_reading.formattedPh}). Apply agricultural lime to raise pH for crop safety.';
    }
    if (_reading.nitrogenStatus == SoilMetricStatus.criticalLow) {
      return '💡 Nitrogen deficiency detected. Apply compost or targeted nitrogenous fertilizer.';
    }
    return '🌱 All soil metrics are in balanced agronomic condition for maximum seasonal crop yield.';
  }

  /// Refreshes telemetry data directly from Chetan's Firestore collection.
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    if (_telemetryRepo != null) {
      final latest = await _telemetryRepo!.getLatestReading(
        farmerId: 'farmer_chaitanya_01',
        deviceId: _deviceId,
      );
      if (latest != null) {
        _reading = latest.reading;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }

    _lastUpdated = DateTime.now();
    _isLoading = false;
    notifyListeners();
  }

  /// Switches sensor scenario to demonstrate real-time UI reactions during viva/evaluation.
  void selectScenario(String scenario) {
    _currentScenario = scenario;
    switch (scenario) {
      case 'Optimal Agronomic Soil':
        _reading = const SoilReadingModel(
          ph: 6.8,
          moisture: 55.0,
          nitrogen: 95.0,
          phosphorus: 38.0,
          potassium: 185.0,
          temperature: 24.5,
          humidity: 62.0,
        );
        break;

      case 'Acidic Drought Alert':
        _reading = const SoilReadingModel(
          ph: 4.8,
          moisture: 14.5,
          nitrogen: 22.0,
          phosphorus: 8.5,
          potassium: 45.0,
          temperature: 36.2,
          humidity: 22.0,
        );
        break;

      case 'Waterlogged & High NPK':
        _reading = const SoilReadingModel(
          ph: 8.9,
          moisture: 91.0,
          nitrogen: 240.0,
          phosphorus: 85.0,
          potassium: 390.0,
          temperature: 18.0,
          humidity: 88.5,
        );
        break;
    }
    _lastUpdated = DateTime.now();
    notifyListeners();
  }
}
