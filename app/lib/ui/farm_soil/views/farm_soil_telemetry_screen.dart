import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';
import '../../dashboard/widgets/soil_health_gauge_card.dart';
import '../../dashboard/widgets/sensor_metric_card.dart';

/// Full Multi-Sensor Farm Telemetry & IoT Node Screen.
class FarmSoilTelemetryScreen extends StatelessWidget {
  const FarmSoilTelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = SmartSoilScope.of(context);
    final lang = scope.language;
    final vm = scope.dashboard;
    final reading = vm.reading;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: SmartSoilTheme.emeraldGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.tr('device_status'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: SmartSoilTheme.textDark,
                      ),
                    ),
                    Text(
                      'ESP32_AI12_NODE_01 • ${lang.tr('status_online')}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: SmartSoilTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.science_outlined, color: SmartSoilTheme.forestGreen),
                tooltip: 'Viva Simulation Scenarios',
                onSelected: (s) => vm.selectScenario(s),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'Optimal Agronomic Soil',
                    child: Text(lang.tr('scenario_optimal')),
                  ),
                  PopupMenuItem(
                    value: 'Acidic Drought Alert',
                    child: Text(lang.tr('scenario_drought')),
                  ),
                  PopupMenuItem(
                    value: 'Waterlogged & High NPK',
                    child: Text(lang.tr('scenario_waterlogged')),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoilHealthGaugeCard(viewModel: vm),
        const SizedBox(height: 14),
        SensorMetricCard(
          title: lang.tr('soil_moisture'),
          formattedValue: reading.formattedMoisture,
          status: reading.moistureStatus,
          icon: Icons.water_drop_outlined,
          referenceRange: '40 - 70 %',
          subtitle: 'Target: 50-70%',
        ),
        const SizedBox(height: 10),
        SensorMetricCard(
          title: lang.tr('soil_ph'),
          formattedValue: reading.formattedPh,
          status: reading.phStatus,
          icon: Icons.science_outlined,
          referenceRange: '6.0 - 7.5 pH',
          subtitle: 'Target: 6.5-7.0',
        ),
        const SizedBox(height: 10),
        SensorMetricCard(
          title: lang.tr('nitrogen'),
          formattedValue: reading.formattedNitrogen,
          status: reading.nitrogenStatus,
          icon: Icons.grass_outlined,
          referenceRange: '50 - 140 mg/kg',
          subtitle: 'Soil Nitrate Pool',
        ),
        const SizedBox(height: 10),
        SensorMetricCard(
          title: lang.tr('phosphorus'),
          formattedValue: reading.formattedPhosphorus,
          status: reading.phosphorusStatus,
          icon: Icons.bubble_chart_outlined,
          referenceRange: '20 - 50 mg/kg',
          subtitle: 'Available Phosphate',
        ),
        const SizedBox(height: 10),
        SensorMetricCard(
          title: lang.tr('potassium'),
          formattedValue: reading.formattedPotassium,
          status: reading.potassiumStatus,
          icon: Icons.shield_outlined,
          referenceRange: '100 - 250 mg/kg',
          subtitle: 'Available Potash',
        ),
        const SizedBox(height: 10),
        SensorMetricCard(
          title: lang.tr('climate'),
          formattedValue: '${reading.formattedTemperature} • ${reading.formattedHumidity}',
          status: reading.temperatureStatus,
          icon: Icons.thermostat_outlined,
          referenceRange: '18 - 30 °C',
          subtitle: 'ESP32 Ambient Probes',
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
