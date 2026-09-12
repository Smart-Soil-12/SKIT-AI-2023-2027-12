import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/smart_soil.dart';
import '../mocks/mock_soil_payloads.dart';

void main() {
  group('CloudSoilRecordModel Serialization & Parsing', () {
    test('parses full cloud soil record from Firestore format', () {
      final record = CloudSoilRecordModel.fromJson(MockSoilPayloads.fullCloudSoilRecordPayload);

      expect(record.id, 'rec_soil_20260815_001');
      expect(record.farmerId, 'farmer_chaitanya_01');
      expect(record.deviceId, 'ESP32_SMART_SOIL_001');
      expect(record.isSimulated, isTrue);
      expect(record.timestamp.year, 2026);
      expect(record.timestamp.month, 8);
      expect(record.timestamp.day, 15);

      // Verify nested reading
      expect(record.reading.ph, 6.8);
      expect(record.reading.moisture, 55.0);
      expect(record.reading.nitrogen, 95.0);
      expect(record.reading.isComplete, isTrue);

      // Verify metadata
      expect(record.metadata?['battery_level'], 94);
      expect(record.metadata?['wifi_rssi'], -62);
    });

    test('serializes back to JSON and roundtrips without losing data', () {
      final original = CloudSoilRecordModel.fromJson(MockSoilPayloads.fullCloudSoilRecordPayload);
      final json = original.toJson();

      expect(json['id'], 'rec_soil_20260815_001');
      expect(json['farmer_id'], 'farmer_chaitanya_01');
      expect(json['device_id'], 'ESP32_SMART_SOIL_001');
      expect(json['is_simulated'], isTrue);
      expect(json['reading']['ph'], 6.8);
      expect(json['metadata']['firmware_version'], '1.0.0-alpha');

      final reconstructed = CloudSoilRecordModel.fromJson(json);
      expect(reconstructed.id, original.id);
      expect(reconstructed.farmerId, original.farmerId);
      expect(reconstructed.reading.ph, original.reading.ph);
    });

    test('handles epoch integer timestamps (milliseconds and seconds)', () {
      // 1786675200000 -> 2026-08-15 00:00:00 UTC
      final recordMillis = CloudSoilRecordModel.fromJson({
        'id': 'test_millis',
        'timestamp': 1786675200000,
        'reading': MockSoilPayloads.optimalSoilPayload,
      });
      expect(recordMillis.timestamp.millisecondsSinceEpoch, 1786675200000);

      final recordSeconds = CloudSoilRecordModel.fromJson({
        'id': 'test_seconds',
        'timestamp': 1786675200,
        'reading': MockSoilPayloads.optimalSoilPayload,
      });
      expect(recordSeconds.timestamp.millisecondsSinceEpoch, 1786675200000);
    });

    test('parses flat root-level telemetry map into nested reading model gracefully', () {
      final flatMap = {
        'id': 'flat_record_123',
        'farmer_id': 'farmer_77',
        'device_id': 'ESP32_DEV_77',
        'ph': 7.0,
        'moisture': 50.0,
        'nitrogen': 100.0,
        'phosphorus': 30.0,
        'potassium': 150.0,
        'temperature': 25.0,
        'humidity': 55.0,
      };

      final record = CloudSoilRecordModel.fromJson(flatMap);
      expect(record.farmerId, 'farmer_77');
      expect(record.reading.ph, 7.0);
      expect(record.reading.moisture, 50.0);
    });
  });
}
