/// Represents the health status level of a specific soil parameter.
enum SoilMetricStatus {
  criticalLow('Critical Low', 'Needs immediate attention', true),
  low('Low', 'Below optimal range', false),
  optimal('Optimal', 'In healthy agronomic range', false),
  high('High', 'Above optimal range', false),
  criticalHigh('Critical High', 'Excessive, may harm crops', true),
  unknown('Unknown', 'Reading missing or unverified', true);

  const SoilMetricStatus(this.label, this.description, this.isAlert);

  final String label;
  final String description;
  final bool isAlert;

  /// Returns true if the status is within safe/favorable bounds.
  bool get isHealthy => this == SoilMetricStatus.optimal;

  /// Returns a severity level for sorting/prioritizing UI alerts (0=Normal, 2=Severe).
  int get severityLevel {
    switch (this) {
      case SoilMetricStatus.optimal:
        return 0;
      case SoilMetricStatus.low:
      case SoilMetricStatus.high:
        return 1;
      case SoilMetricStatus.criticalLow:
      case SoilMetricStatus.criticalHigh:
      case SoilMetricStatus.unknown:
        return 2;
    }
  }
}
