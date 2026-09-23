import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';

/// AI Crop Yield Prediction & Soil Nutrient Analytics Screen.
class YieldPredictionScreen extends StatelessWidget {
  const YieldPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = SmartSoilScope.of(context);
    final lang = scope.language;
    final yieldVm = scope.yieldVm;
    final reading = scope.dashboard.reading;

    final yieldPerAcre = yieldVm.calculateYieldPerAcre(reading);
    final totalHarvest = yieldVm.calculateTotalHarvest(reading);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          lang.tr('yield_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: SmartSoilTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang.tr('yield_subtitle'),
          style: const TextStyle(
            fontSize: 12,
            color: SmartSoilTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.tr('select_crop'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SmartSoilTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: SmartSoilTheme.creamBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.08)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: yieldVm.selectedCrop,
                      isExpanded: true,
                      items: yieldVm.crops.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) yieldVm.setCrop(val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.tr('farm_size'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: SmartSoilTheme.textDark,
                      ),
                    ),
                    Text(
                      '${yieldVm.farmSizeAcres.toStringAsFixed(1)} Acres',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SmartSoilTheme.forestGreen,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: yieldVm.farmSizeAcres,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  activeColor: SmartSoilTheme.forestGreen,
                  onChanged: (val) => yieldVm.setFarmSize(val),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SmartSoilTheme.forestGreen, SmartSoilTheme.emeraldGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: SmartSoilTheme.forestGreen.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.tr('predicted_yield'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.analytics_rounded, color: Colors.white),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$yieldPerAcre',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lang.tr('per_acre'),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.tr('total_harvest'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$totalHarvest Quintals (क्विंटल)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: SmartSoilTheme.warningOrange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    lang.tr('optimization_tip'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: SmartSoilTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Current Soil Health Score (${reading.healthScore}/100): Nitrogen is ${reading.formattedNitrogen}, Moisture is ${reading.formattedMoisture}. Maintain balanced urea and potash split-dosing to reach maximum yield potential.',
                style: const TextStyle(
                  fontSize: 12,
                  color: SmartSoilTheme.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
