/// Simulated soil telemetry payloads mimicking data streams from
/// Chetan's backend (FastAPI), Firebase Firestore, and Aryan's ESP32 sensor module.
class MockSoilPayloads {
  MockSoilPayloads._();

  /// Ideal, healthy agronomic parameters
  static const Map<String, dynamic> optimalSoilPayload = {
    'ph': 6.8,
    'moisture': 55.0,
    'nitrogen': 95.0,
    'phosphorus': 38.0,
    'potassium': 185.0,
    'temperature': 24.5,
    'humidity': 62.0,
  };

  /// Acidic, drought condition with nutrient deficiency
  static const Map<String, dynamic> acidicDrySoilPayload = {
    'ph': 4.8,
    'moisture': 14.5,
    'nitrogen': 22.0,
    'phosphorus': 8.5,
    'potassium': 45.0,
    'temperature': 36.2,
    'humidity': 22.0,
  };

  /// Alkaline, waterlogged soil with excessive fertilizer
  static const Map<String, dynamic> alkalineWaterloggedPayload = {
    'ph': 8.9,
    'moisture': 91.0,
    'nitrogen': 240.0,
    'phosphorus': 85.0,
    'potassium': 390.0,
    'temperature': 18.0,
    'humidity': 88.5,
  };

  /// ESP32 IoT transmission where values arrive as string numbers and alternative keys
  static const Map<String, dynamic> stringEncodedIotPayload = {
    'ph': '7.2',
    'soil_moisture': '58.4',
    'n': '110',
    'p': '42',
    'k': '195',
    'temp': '26.8',
    'ambient_humidity': '65.0',
  };

  /// Partial payload with missing/null values to verify defensive fallbacks
  static const Map<String, dynamic> partialPayloadWithNulls = {
    'ph': 6.5,
    'moisture': null,
    'nitrogen': 80.0,
    'phosphorus': null,
    'potassium': 150.0,
    'temperature': null,
  };

  /// Complete cloud record payload representing a Firestore document
  static const Map<String, dynamic> fullCloudSoilRecordPayload = {
    'id': 'rec_soil_20260815_001',
    'farmer_id': 'farmer_chaitanya_01',
    'device_id': 'ESP32_SMART_SOIL_001',
    'timestamp': '2026-08-15T10:30:00.000Z',
    'is_simulated': true,
    'reading': {
      'ph': 6.8,
      'moisture': 55.0,
      'nitrogen': 95.0,
      'phosphorus': 38.0,
      'potassium': 185.0,
      'temperature': 24.5,
      'humidity': 62.0,
    },
    'metadata': {
      'battery_level': 94,
      'wifi_rssi': -62,
      'firmware_version': '1.0.0-alpha',
    },
  };
}
