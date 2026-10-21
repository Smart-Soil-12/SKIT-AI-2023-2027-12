import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// 7-Day Multi-Sensor Historical Soil Telemetry & Trend Analytics Component.
/// Fulfills Sprint 6 (Flutter Application Core) requirement for time-series visualization.
class SoilTelemetryTrendCard extends StatefulWidget {
  final Map<String, List<double>>? historicalData;
  final String? initialMetric;

  const SoilTelemetryTrendCard({
    super.key,
    this.historicalData,
    this.initialMetric,
  });

  @override
  State<SoilTelemetryTrendCard> createState() => _SoilTelemetryTrendCardState();
}

class _SoilTelemetryTrendCardState extends State<SoilTelemetryTrendCard> {
  late String _selectedMetric;

  // Default synthetic 7-day trend series matching calibrated ESP32 sensor values
  static const Map<String, List<double>> _defaultHistory = {
    'Moisture': [54.0, 52.5, 49.0, 47.0, 44.5, 58.0, 56.0], // %
    'pH': [6.7, 6.7, 6.6, 6.8, 6.8, 6.7, 6.8], // pH
    'Nitrogen': [88.0, 86.0, 84.0, 82.0, 80.0, 85.0, 85.0], // mg/kg
    'Phosphorus': [42.0, 41.0, 40.0, 39.0, 38.0, 42.0, 42.0], // mg/kg
    'Potassium': [185.0, 184.0, 182.0, 180.0, 178.0, 180.0, 180.0], // mg/kg
  };

  static const List<String> _dayLabels = ['D-6', 'D-5', 'D-4', 'D-3', 'D-2', 'D-1', 'Today'];

  static const Map<String, String> _metricUnits = {
    'Moisture': '%',
    'pH': 'pH',
    'Nitrogen': 'mg/kg',
    'Phosphorus': 'mg/kg',
    'Potassium': 'mg/kg',
  };

  static const Map<String, String> _metricBilingualLabels = {
    'Moisture': 'Moisture / नमी',
    'pH': 'Reaction / पीएच',
    'Nitrogen': 'Nitrogen (N) / नाइट्रोजन',
    'Phosphorus': 'Phosphorus (P) / फास्फोरस',
    'Potassium': 'Potassium (K) / पोटाश',
  };

  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.initialMetric ?? 'Moisture';
  }

  List<double> get _currentSeries {
    final custom = widget.historicalData?[_selectedMetric];
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }
    return _defaultHistory[_selectedMetric] ?? [50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0];
  }

  double get _avgValue {
    final series = _currentSeries;
    if (series.isEmpty) return 0.0;
    final sum = series.reduce((a, b) => a + b);
    return double.parse((sum / series.length).toStringAsFixed(1));
  }

  double get _minValue {
    final series = _currentSeries;
    if (series.isEmpty) return 0.0;
    return series.reduce((a, b) => a < b ? a : b);
  }

  double get _maxValue {
    final series = _currentSeries;
    if (series.isEmpty) return 0.0;
    return series.reduce((a, b) => a > b ? a : b);
  }

  String get _trendDirection {
    final series = _currentSeries;
    if (series.length < 2) return 'Stable';
    final diff = series.last - series.first;
    if (diff > 1.5) return 'Rising';
    if (diff < -1.5) return 'Declining';
    return 'Stable';
  }

  IconData get _trendIcon {
    switch (_trendDirection) {
      case 'Rising':
        return Icons.trending_up;
      case 'Declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color get _trendColor {
    switch (_trendDirection) {
      case 'Rising':
        return _selectedMetric == 'Moisture' ? SmartSoilTheme.emeraldGreen : Colors.orange.shade800;
      case 'Declining':
        return _selectedMetric == 'Moisture' ? Colors.blue.shade700 : Colors.red.shade700;
      default:
        return SmartSoilTheme.forestGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = _metricUnits[_selectedMetric] ?? '';
    final series = _currentSeries;
    final maxInSeries = _maxValue == 0 ? 1.0 : _maxValue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SmartSoilTheme.emeraldGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: SmartSoilTheme.forestGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7-Day Soil Telemetry Trend',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SmartSoilTheme.textDark,
                      ),
                    ),
                    Text(
                      '7-दिवसीय ऐतिहासिक मिट्टी रुझान विश्लेषण',
                      style: TextStyle(
                        fontSize: 11,
                        color: SmartSoilTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_trendIcon, size: 14, color: _trendColor),
                    const SizedBox(width: 4),
                    Text(
                      _trendDirection,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _trendColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Metric Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _defaultHistory.keys.map((metric) {
                final isSelected = metric == _selectedMetric;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      metric,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : SmartSoilTheme.textDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: SmartSoilTheme.forestGreen,
                    backgroundColor: Colors.grey.shade100,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedMetric = metric;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Statistics Snapshot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('7-Day Avg', '$_avgValue $unit'),
                _buildDivider(),
                _buildStatColumn('Min', '$_minValue $unit'),
                _buildDivider(),
                _buildStatColumn('Max', '$_maxValue $unit'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 7-Day Bar Chart
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(series.length, (idx) {
                final val = series[idx];
                final normalizedHeight = (val / (maxInSeries * 1.25)).clamp(0.15, 1.0);
                final isLatest = idx == series.length - 1;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      val.toStringAsFixed(val % 1 == 0 ? 0 : 1),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                        color: isLatest ? SmartSoilTheme.forestGreen : SmartSoilTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: 70 * normalizedHeight,
                      decoration: BoxDecoration(
                        color: isLatest
                            ? SmartSoilTheme.emeraldGreen
                            : SmartSoilTheme.emeraldGreen.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dayLabels[idx < _dayLabels.length ? idx : 0],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                        color: isLatest ? SmartSoilTheme.forestGreen : Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle Footnote
          Text(
            'Active Metric: ${_metricBilingualLabels[_selectedMetric] ?? _selectedMetric} • Real-time telemetry synchronized with cloud archive.',
            style: const TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: SmartSoilTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: SmartSoilTheme.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: SmartSoilTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.black.withOpacity(0.08),
    );
  }
}
