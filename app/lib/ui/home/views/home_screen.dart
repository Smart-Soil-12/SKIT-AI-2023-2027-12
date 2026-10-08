import 'package:flutter/material.dart';
import '../../../core/state/smart_soil_scope.dart';
import '../../dashboard/widgets/crop_recommendation_card.dart';
import '../widgets/hero_crop_scanner_card.dart';
import '../widgets/weather_risk_card.dart';
import '../widgets/soil_telemetry_summary.dart';
import '../widgets/farmers_news_section.dart';

/// Primary Smart Soil Home Screen matching the AgriVision layout.
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToScan;
  final VoidCallback onNavigateToFarm;

  const HomeScreen({
    super.key,
    required this.onNavigateToScan,
    required this.onNavigateToFarm,
  });

  @override
  Widget build(BuildContext context) {
    final scope = SmartSoilScope.of(context);
    final vm = scope.dashboard;
    final cropVm = scope.cropVm;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          vm.refreshData(),
          cropVm.loadRecommendations('farmer_chaitanya_01'),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          HeroCropScannerCard(onOpenScanner: onNavigateToScan),
          const SizedBox(height: 16),
          const WeatherRiskCard(),
          const SizedBox(height: 16),
          if (cropVm.result != null) ...[
            CropRecommendationCard(
              recommendationResult: cropVm.result!,
              onRefresh: () => cropVm.loadRecommendations('farmer_chaitanya_01'),
            ),
            const SizedBox(height: 16),
          ],
          SoilTelemetrySummary(onViewFullTelemetry: onNavigateToFarm),
          const SizedBox(height: 20),
          const FarmersNewsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

