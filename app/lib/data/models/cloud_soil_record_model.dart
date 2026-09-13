import 'soil_reading_model.dart';

/// Data model representing a timestamped, farmer-linked cloud soil telemetry record.
///
/// Designed to interface with Firebase Firestore real-time streams
/// and FastAPI historical retrieval endpoints.
class CloudSoilRecordModel {
  final String id;
  final String farmerId;
  final String deviceId;
  final DateTime timestamp;
  final SoilReadingModel reading;
  final bool isSimulated;
  final Map<String, dynamic>? metadata;

  const CloudSoilRecordModel({
    required this.id,
    required this.farmerId,
    required this.deviceId,
    required this.timestamp,
    required this.reading,
    this.isSimulated = false,
    this.metadata,
  });

  /// Factory to deserialize a JSON payload from FastAPI or WebSocket streams.
  factory CloudSoilRecordModel.fromJson(Map<String, dynamic> json, [String? id]) {
    final recordId = id ?? json['id']?.toString() ?? json['record_id']?.toString() ?? '';
    final farmerId = json['farmer_id']?.toString() ?? json['farmerId']?.toString() ?? 'unknown_farmer';
    final deviceId = json['device_id']?.toString() ?? json['deviceId']?.toString() ?? 'unknown_device';
    final isSimulated = json['is_simulated'] == true || json['isSimulated'] == true;

    // Handle flexible timestamp formats (ISO8601 string, epoch millis, or Firestore map)
    final DateTime parsedTimestamp = _parseTimestamp(json['timestamp'] ?? json['created_at']);

    // Extract nested reading or parse from root
    final Map<String, dynamic> readingJson;
    if (json.containsKey('reading') && json['reading'] is Map<String, dynamic>) {
      readingJson = json['reading'] as Map<String, dynamic>;
    } else if (json.containsKey('sensor_data') && json['sensor_data'] is Map<String, dynamic>) {
      readingJson = json['sensor_data'] as Map<String, dynamic>;
    } else {
      readingJson = json; // Fallback: metrics located at root level
    }

    final reading = SoilReadingModel.fromJson(readingJson);
    final metadata = json['metadata'] is Map<String, dynamic> ? json['metadata'] as Map<String, dynamic> : null;

    return CloudSoilRecordModel(
      id: recordId,
      farmerId: farmerId,
      deviceId: deviceId,
      timestamp: parsedTimestamp,
      reading: reading,
      isSimulated: isSimulated,
      metadata: metadata,
    );
  }

  /// Factory to deserialize a Firestore document snapshot.
  factory CloudSoilRecordModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return CloudSoilRecordModel.fromJson(data, docId);
  }

  /// Serializes into JSON for API communication.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'device_id': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'is_simulated': isSimulated,
      'reading': reading.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Serializes into Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'farmer_id': farmerId,
      'device_id': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'is_simulated': isSimulated,
      'reading': reading.toFirestore(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Helper to safely parse timestamps across various Firestore and REST formats.
  static DateTime _parseTimestamp(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed;
    }
    if (raw is int) {
      // Check if seconds or milliseconds
      if (raw > 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(raw);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      }
    }
    // Firestore Timestamp representation when serialized as map
    if (raw is Map) {
      if (raw.containsKey('_seconds')) {
        final sec = raw['_seconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(sec * 1000);
      }
    }
    return DateTime.now();
  }
}
