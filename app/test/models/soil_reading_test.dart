import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/smart_soil.dart';
import '../mocks/mock_soil_payloads.dart';

void main() {
  group('SoilReadingModel Deserialization & Serialization', () {
    test('correctly parses optimal soil payload from standard JSON', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.optimalSoilPayload);

      expect(model.ph, 6.8);
      expect(model.moisture, 55.0);
      expect(model.nitrogen, 95.0);
      expect(model.phosphorus, 38.0);
      expect(model.potassium, 185.0);
      expect(model.temperature, 24.5);
      expect(model.humidity, 62.0);

      expect(model.isComplete, isTrue);
      expect(model.isValid, isTrue);
    });

    test('serializes to JSON matching standard backend format', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.optimalSoilPayload);
      final json = model.toJson();

      expect(json['ph'], 6.8);
      expect(json['moisture'], 55.0);
      expect(json['nitrogen'], 95.0);
      expect(json['phosphorus'], 38.0);
      expect(json['potassium'], 185.0);
      expect(json['temperature'], 24.5);
      expect(json['humidity'], 62.0);
    });

    test('correctly parses string-encoded numbers and alternative IoT keys', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.stringEncodedIotPayload);

      expect(model.ph, 7.2);
      expect(model.moisture, 58.4);
      expect(model.nitrogen, 110.0);
      expect(model.phosphorus, 42.0);
      expect(model.potassium, 195.0);
      expect(model.temperature, 26.8);
      expect(model.humidity, 65.0);
      expect(model.isComplete, isTrue);
    });

    test('handles partial payloads with null values defensively without throwing', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.partialPayloadWithNulls);

      expect(model.ph, 6.5);
      expect(model.moisture, isNull);
      expect(model.nitrogen, 80.0);
      expect(model.phosphorus, isNull);
      expect(model.potassium, 150.0);
      expect(model.temperature, isNull);

      expect(model.isComplete, isFalse);
      expect(model.isValid, isTrue);
    });
  });

  group('SoilValidator Boundary & Range Checking', () {
    test('identifies valid ranges for all soil parameters', () {
      expect(SoilValidator.isValidPh(7.0), isTrue);
      expect(SoilValidator.isValidPh(-0.5), isFalse);
      expect(SoilValidator.isValidPh(14.5), isFalse);

      expect(SoilValidator.isValidMoisture(50.0), isTrue);
      expect(SoilValidator.isValidMoisture(-1.0), isFalse);
      expect(SoilValidator.isValidMoisture(101.0), isFalse);

      expect(SoilValidator.isValidNitrogen(100.0), isTrue);
      expect(SoilValidator.isValidNitrogen(-5.0), isFalse);
      expect(SoilValidator.isValidNitrogen(600.0), isFalse);

      expect(SoilValidator.isValidTemperature(25.0), isTrue);
      expect(SoilValidator.isValidTemperature(-15.0), isFalse);
      expect(SoilValidator.isValidTemperature(65.0), isFalse);
    });
  });

  group('Soil Status Categorization & Agronomic Scoring', () {
    test('evaluates optimal health status for balanced readings', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.optimalSoilPayload);

      expect(model.phStatus, SoilMetricStatus.optimal);
      expect(model.moistureStatus, SoilMetricStatus.optimal);
      expect(model.nitrogenStatus, SoilMetricStatus.optimal);
      expect(model.phosphorusStatus, SoilMetricStatus.optimal);
      expect(model.potassiumStatus, SoilMetricStatus.optimal);
      expect(model.temperatureStatus, SoilMetricStatus.optimal);
      expect(model.humidityStatus, SoilMetricStatus.optimal);

      expect(model.healthScore, greaterThanOrEqualTo(90));
    });

    test('evaluates critical low status for severe drought and acid conditions', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.acidicDrySoilPayload);

      expect(model.phStatus, SoilMetricStatus.criticalLow);
      expect(model.moistureStatus, SoilMetricStatus.criticalLow);
      expect(model.nitrogenStatus, SoilMetricStatus.criticalLow);
      expect(model.phosphorusStatus, SoilMetricStatus.criticalLow);
      expect(model.potassiumStatus, SoilMetricStatus.criticalLow);

      expect(model.healthScore, lessThan(60));
    });

    test('evaluates critical high status for waterlogged and over-fertilized soil', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.alkalineWaterloggedPayload);

      expect(model.phStatus, SoilMetricStatus.criticalHigh);
      expect(model.moistureStatus, SoilMetricStatus.criticalHigh);
      expect(model.nitrogenStatus, SoilMetricStatus.criticalHigh);
      expect(model.potassiumStatus, SoilMetricStatus.criticalHigh);
    });
  });

  group('Formatted Display Units & Labels', () {
    test('produces correct user-facing display strings with units', () {
      final model = SoilReadingModel.fromJson(MockSoilPayloads.optimalSoilPayload);

      expect(model.formattedPh, '6.8 pH');
      expect(model.formattedMoisture, '55.0 %');
      expect(model.formattedNitrogen, '95 mg/kg');
      expect(model.formattedPhosphorus, '38 mg/kg');
      expect(model.formattedPotassium, '185 mg/kg');
      expect(model.formattedTemperature, '24.5 °C');
      expect(model.formattedHumidity, '62.0 %');
    });

    test('returns fallback placeholders when values are null', () {
      const model = SoilReadingModel();

      expect(model.formattedPh, '--');
      expect(model.formattedMoisture, '--');
      expect(model.formattedNitrogen, '--');
      expect(model.formattedTemperature, '--');
    });
  });
}
