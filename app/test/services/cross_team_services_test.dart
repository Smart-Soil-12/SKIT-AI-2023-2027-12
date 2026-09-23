import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/core/services/hardware_bridge_service.dart';
import 'package:smart_soil/core/services/ml_engine_service.dart';
import 'package:smart_soil/data/models/soil_reading_model.dart';

void main() {
  group('Sprint 3 Week 2: Aryan HardwareBridgeService (ESP32_AI12_NODE_01)', () {
    late HardwareBridgeService hardwareBridge;

    setUp(() {
      hardwareBridge = HardwareBridgeService();
    });

    test('verifies initial hardware node status and battery level', () {
      expect(hardwareBridge.deviceId, equals('ESP32_AI12_NODE_01'));
      expect(hardwareBridge.status, equals(HardwareNodeStatus.online));
      expect(hardwareBridge.batteryPercent, equals(92));
      expect(hardwareBridge.wifiRssi, equals(-68));
    });

    test('correctly parses raw ESP32 telemetry packet into CloudSoilRecordModel', () {
      final rawPacket = {
        'farmer_id': 'farmer_chaitanya_01',
        'reading': {
          'pH': 6.7,
          'moisture': 56.4,
          'N': 82.0,
          'P': 34.0,
          'K': 170.0,
          'temperature': 25.0,
          'humidity': 63.0,
        }
      };

      final record = hardwareBridge.parseIncomingHardwarePacket(rawPacket);
      expect(record.deviceId, equals('ESP32_AI12_NODE_01'));
      expect(record.reading.ph, equals(6.7));
      expect(record.reading.moisture, equals(56.4));
      expect(record.isSimulated, isFalse);
    });
  });

  group('Sprint 3 Week 2: Abhinav MLEngineService (Inference & Advisory)', () {
    late MLEngineService mlEngine;

    setUp(() {
      mlEngine = MLEngineService();
    });

    test('classifies crop disease correctly with confidence and severity', () {
      final earlyBlight = mlEngine.classifyLeafDisease('sample_early_blight');
      expect(earlyBlight.diseaseName, contains('Tomato Early Blight'));
      expect(earlyBlight.confidence, greaterThan(90.0));
      expect(earlyBlight.treatment, contains('Mancozeb'));

      final healthy = mlEngine.classifyLeafDisease('sample_healthy');
      expect(healthy.diseaseName, contains('Healthy'));
      expect(healthy.severity, contains('Optimal'));
    });

    test('predicts crop yield correctly using soil NPK and acreage', () {
      const reading = SoilReadingModel(
        ph: 6.8,
        moisture: 60.0,
        nitrogen: 90.0,
        phosphorus: 40.0,
        potassium: 180.0,
        temperature: 25.0,
        humidity: 60.0,
      );

      final yieldPerAcre = mlEngine.calculatePredictedYield(
        crop: 'Wheat (गेहूं)',
        farmSizeAcres: 5.0,
        reading: reading,
      );

      expect(yieldPerAcre, greaterThan(15.0));
      expect(yieldPerAcre, lessThan(35.0));
    });

    test('generates contextual agronomic advice referencing live telemetry', () {
      const reading = SoilReadingModel(
        ph: 5.2,
        moisture: 30.0,
        nitrogen: 40.0,
        phosphorus: 20.0,
        potassium: 100.0,
        temperature: 28.0,
        humidity: 50.0,
      );

      final advicePh = mlEngine.generateAgronomicAdvice(
        query: 'What fertilizer for this soil pH?',
        currentSoil: reading,
      );
      expect(advicePh, contains('5.2'));

      final adviceMoisture = mlEngine.generateAgronomicAdvice(
        query: 'Is moisture sufficient?',
        currentSoil: reading,
      );
      expect(adviceMoisture, contains('30.0 %'));
    });
  });
}
