import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';
import '../../dashboard/widgets/soil_health_gauge_card.dart';

/// Soil Telemetry Summary Widget featuring Health Gauge & Mini Sensor Badges.
class SoilTelemetrySummary extends StatelessWidget {
  final VoidCallback onViewFullTelemetry;

  const SoilTelemetrySummary({
    super.key,
    required this.onViewFullTelemetry,
  });

  @override
  Widget build(BuildContext context) {
    final scope = SmartSoilScope.of(context);
    final lang = scope.language;
    final reading = scope.dashboard.reading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang.tr('soil_health_index'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SmartSoilTheme.textDark,
              ),
            ),
            TextButton(
              onPressed: onViewFullTelemetry,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.tr('tab_farm'),
                    style: const TextStyle(
                      color: SmartSoilTheme.forestGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: SmartSoilTheme.forestGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SoilHealthGaugeCard(viewModel: scope.dashboard),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMiniMetric(
                label: lang.tr('soil_moisture'),
                value: reading.formattedMoisture,
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF0288D1),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniMetric(
                label: lang.tr('soil_ph'),
                value: reading.formattedPh,
                icon: Icons.science_rounded,
                color: const Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMiniMetric(
                label: lang.tr('nitrogen'),
                value: reading.formattedNitrogen,
                icon: Icons.grass_rounded,
                color: SmartSoilTheme.emeraldGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: SmartSoilTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: SmartSoilTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
