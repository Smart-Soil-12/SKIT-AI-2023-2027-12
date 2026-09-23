import '../../data/models/cloud_soil_record_model.dart';
import '../../data/models/soil_reading_model.dart';

/// Connection states for the physical ESP32 IoT Node.
enum HardwareNodeStatus { online, syncing, offline }

/// Hardware Bridge that ingests telemetry from Aryan's ESP32 hardware node.
/// Follows contracts/soil_telemetry_schema.json specs (Node: ESP32_AI12_NODE_01).
class HardwareBridgeService {
  final String deviceId;
  HardwareNodeStatus _status = HardwareNodeStatus.online;
  int _batteryPercent = 92;
  int _wifiRssi = -68; // dBm
  final String _firmwareVersion = 'v1.2.0-esp32';

  HardwareBridgeService({this.deviceId = 'ESP32_AI12_NODE_01'});

  HardwareNodeStatus get status => _status;
  int get batteryPercent => _batteryPercent;
  int get wifiRssi => _wifiRssi;
  String get firmwareVersion => _firmwareVersion;
  bool get isOnline => _status == HardwareNodeStatus.online;

  /// Simulates parsing incoming serial / MQTT packet from ESP32.
  CloudSoilRecordModel parseIncomingHardwarePacket(Map<String, dynamic> rawPacket) {
    final readingData = rawPacket['reading'] as Map<String, dynamic>? ?? rawPacket;
    final reading = SoilReadingModel.fromJson(readingData);

    return CloudSoilRecordModel(
      id: 'hw_${DateTime.now().millisecondsSinceEpoch}',
      farmerId: rawPacket['farmer_id']?.toString() ?? 'farmer_chaitanya_01',
      deviceId: deviceId,
      timestamp: DateTime.now().toUtc(),
      isSimulated: false,
      reading: reading,
    );
  }

  /// Sets device status for viva demonstration.
  void setSimulationStatus(HardwareNodeStatus newStatus, {int? battery, int? rssi}) {
    _status = newStatus;
    if (battery != null) _batteryPercent = battery;
    if (rssi != null) _wifiRssi = rssi;
  }
}
