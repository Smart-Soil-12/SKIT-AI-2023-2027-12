import '../../core/app_theme.dart';
import 'package:flutter/material.dart';

import '../view_models/dashboard_view_model.dart';
import '../widgets/agronomic_alert_banner.dart';
import '../widgets/sensor_metric_card.dart';
import '../widgets/soil_health_gauge_card.dart';

/// Primary Android Material 3 Dashboard Screen for the Smart Soil mobile application.
class SoilDashboardScreen extends StatefulWidget {
  const SoilDashboardScreen({super.key});

  @override
  State<SoilDashboardScreen> createState() => _SoilDashboardScreenState();
}

class _SoilDashboardScreenState extends State<SoilDashboardScreen> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final reading = _viewModel.reading;

        return Scaffold(
          appBar: AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.agriculture_rounded, size: 22, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Smart Soil'),
                  ],
                ),
                Text(
                  'Precision Agriculture Dashboard',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w400, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              // Live Viva / Evaluation Scenario Switcher
              PopupMenuButton<String>(
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                tooltip: 'Switch Telemetry Scenario (Viva Demo)',
                onSelected: (scenario) => _viewModel.selectScenario(scenario),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Optimal Agronomic Soil',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: AppTheme.statusOptimal, size: 18),
                        SizedBox(width: 8),
                        Text('Optimal Soil (Healthy)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Acidic Drought Alert',
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppTheme.statusCritical, size: 18),
                        SizedBox(width: 8),
                        Text('Acidic Drought Alert'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Waterlogged & High NPK',
                    child: Row(
                      children: [
                        Icon(Icons.water_rounded, color: AppTheme.statusWarning, size: 18),
                        SizedBox(width: 8),
                        Text('Waterlogged & High NPK'),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: _viewModel.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Refresh ESP32 Telemetry',
                onPressed: _viewModel.isLoading ? null : () => _viewModel.refreshData(),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _viewModel.refreshData(),
            color: AppTheme.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Scenario Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sensors_rounded, size: 16, color: Color(0xFF475569)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Active Feed: ${_viewModel.currentScenario}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                        const Text(
                          'Tap ⚙️ to toggle',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 1. Circular Composite Soil Health Gauge
                  SoilHealthGaugeCard(viewModel: _viewModel),

                  const SizedBox(height: 20),

                  // 2. Telemetry Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'REAL-TIME SENSOR METRICS',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        'ESP32 Telemetry',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 3. Grid of Sensor Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.15,
                    children: [
                      // Moisture
                      SensorMetricCard(
                        title: 'Soil Moisture',
                        formattedValue: reading.formattedMoisture,
                        status: reading.moistureStatus,
                        icon: Icons.water_drop_rounded,
                        referenceRange: '40 - 70 %',
                      ),
                      // pH Level
                      SensorMetricCard(
                        title: 'Soil pH Level',
                        formattedValue: reading.formattedPh,
                        status: reading.phStatus,
                        icon: Icons.science_rounded,
                        referenceRange: '6.0 - 7.5 pH',
                      ),
                      // Nitrogen
                      SensorMetricCard(
                        title: 'Nitrogen (N)',
                        formattedValue: reading.formattedNitrogen,
                        status: reading.nitrogenStatus,
                        icon: Icons.grass_rounded,
                        referenceRange: '50 - 140 mg/kg',
                      ),
                      // Phosphorus
                      SensorMetricCard(
                        title: 'Phosphorus (P)',
                        formattedValue: reading.formattedPhosphorus,
                        status: reading.phosphorusStatus,
                        icon: Icons.spa_rounded,
                        referenceRange: '20 - 50 mg/kg',
                      ),
                      // Potassium
                      SensorMetricCard(
                        title: 'Potassium (K)',
                        formattedValue: reading.formattedPotassium,
                        status: reading.potassiumStatus,
                        icon: Icons.compost_rounded,
                        referenceRange: '100 - 250 mg/kg',
                      ),
                      // Temperature & Air Humidity
                      SensorMetricCard(
                        title: 'Soil Temp',
                        formattedValue: reading.formattedTemperature,
                        status: reading.temperatureStatus,
                        icon: Icons.thermostat_rounded,
                        referenceRange: '18 - 30 °C',
                        subtitle: 'Air Hum: ${reading.formattedHumidity}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 4. Agronomic Advisory Section
                  const Text(
                    'ADVISORY & ACTIONABLE ALERTS',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Color(0xFF475569),
                    ),
                  ),

                  const SizedBox(height: 10),

                  AgronomicAlertBanner(viewModel: _viewModel),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
