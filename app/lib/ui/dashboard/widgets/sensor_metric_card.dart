import '../../core/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../../smart_soil.dart';


/// Material 3 Card displaying an individual soil or environmental metric.
class SensorMetricCard extends StatelessWidget {
  final String title;
  final String formattedValue;
  final SoilMetricStatus status;
  final IconData icon;
  final String referenceRange;
  final String? subtitle;

  const SensorMetricCard({
    super.key,
    required this.title,
    required this.formattedValue,
    required this.status,
    required this.icon,
    required this.referenceRange,
    this.subtitle,
  });

  Color _getStatusColor() {
    switch (status) {
      case SoilMetricStatus.optimal:
        return AppTheme.statusOptimal;
      case SoilMetricStatus.low:
      case SoilMetricStatus.high:
        return AppTheme.statusWarning;
      case SoilMetricStatus.criticalLow:
      case SoilMetricStatus.criticalHigh:
        return AppTheme.statusCritical;
      case SoilMetricStatus.unknown:
        return AppTheme.statusNeutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon & Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: statusColor, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Middle: Title & Value
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  formattedValue,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Bottom: Reference Target
            Row(
              children: [
                const Icon(Icons.info_outline, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle ?? 'Ideal: $referenceRange',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
