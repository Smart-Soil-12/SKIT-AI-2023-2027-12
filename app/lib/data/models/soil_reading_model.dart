import '../../core/utils/soil_validator.dart';
import '../../domain/models/soil_reading.dart';

/// Data layer model for [SoilReading] with JSON and Firestore serialization.
class SoilReadingModel extends SoilReading {
  const SoilReadingModel({
    super.ph,
    super.moisture,
    super.nitrogen,
    super.phosphorus,
    super.potassium,
    super.temperature,
    super.humidity,
  });

  /// Factory constructor to convert from a domain entity.
  factory SoilReadingModel.fromDomain(SoilReading entity) {
    return SoilReadingModel(
      ph: entity.ph,
      moisture: entity.moisture,
      nitrogen: entity.nitrogen,
      phosphorus: entity.phosphorus,
      potassium: entity.potassium,
      temperature: entity.temperature,
      humidity: entity.humidity,
    );
  }

  /// Deserializes a JSON map from REST API (FastAPI) or IoT payload into [SoilReadingModel].
  ///
  /// Supports key variations used across backend and IoT modules:
  /// - `ph`
  /// - `moisture` | `soil_moisture`
  /// - `nitrogen` | `n` | `N`
  /// - `phosphorus` | `p` | `P`
  /// - `potassium` | `k` | `K`
  /// - `temperature` | `temp`
  /// - `humidity` | `ambient_humidity`
  factory SoilReadingModel.fromJson(Map<String, dynamic> json) {
    return SoilReadingModel(
      ph: SoilValidator.parseNumeric(json['ph'] ?? json['pH']),
      moisture: SoilValidator.parseNumeric(json['moisture'] ?? json['soil_moisture']),
      nitrogen: SoilValidator.parseNumeric(json['nitrogen'] ?? json['n'] ?? json['N']),
      phosphorus: SoilValidator.parseNumeric(json['phosphorus'] ?? json['p'] ?? json['P']),
      potassium: SoilValidator.parseNumeric(json['potassium'] ?? json['k'] ?? json['K']),
      temperature: SoilValidator.parseNumeric(json['temperature'] ?? json['temp']),
      humidity: SoilValidator.parseNumeric(json['humidity'] ?? json['ambient_humidity']),
    );
  }

  /// Deserializes a Firestore document snapshot map into [SoilReadingModel].
  factory SoilReadingModel.fromFirestore(Map<String, dynamic> data) {
    return SoilReadingModel.fromJson(data);
  }

  /// Serializes the model into a standard JSON map for REST API communication.
  Map<String, dynamic> toJson() {
    return {
      'ph': ph,
      'moisture': moisture,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  /// Serializes the model into a Firestore-friendly document field map.
  Map<String, dynamic> toFirestore() {
    return {
      'ph': ph,
      'moisture': moisture,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  /// Returns a copy with specified fields replaced.
  SoilReadingModel copyWith({
    double? ph,
    double? moisture,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    double? temperature,
    double? humidity,
  }) {
    return SoilReadingModel(
      ph: ph ?? this.ph,
      moisture: moisture ?? this.moisture,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
    );
  }
}
