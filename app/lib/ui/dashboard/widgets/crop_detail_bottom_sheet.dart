import 'package:flutter/material.dart';
import '../../../data/models/crop_recommendation_model.dart';

/// Interactive Agronomic Detail & Fertilizer Advisory Sheet for Smart Soil.
/// Fulfills Form-1 Objective 3 & Form-2 Sprint 5 Week 2 Task:
/// "Prepare Flutter response structure for top-3 crop & verified output fields for API integration & recommendation display."
class CropDetailBottomSheet extends StatelessWidget {
  final CropRecommendationItem crop;
  final Map<String, double> currentSoil;

  const CropDetailBottomSheet({
    super.key,
    required this.crop,
    required this.currentSoil,
  });

  static void show(
    BuildContext context, {
    required CropRecommendationItem crop,
    required Map<String, double> currentSoil,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CropDetailBottomSheet(
        crop: crop,
        currentSoil: currentSoil,
      ),
    );
  }

  // Bilingual Hindi mapping for prominent crops
  static const Map<String, String> _hindiCropNames = {
    'Wheat': 'गेहूँ (Wheat)',
    'Rice': 'चावल / धान (Rice)',
    'Maize': 'मक्का (Maize)',
    'Chickpea': 'चना (Chickpea)',
    'Cotton': 'कपास (Cotton)',
    'Kidneybeans': 'राजमा (Kidney Beans)',
    'Pigeonpeas': 'अरहर / तूर (Pigeon Peas)',
    'Mothbeans': 'मोठ (Moth Beans)',
    'Mungbean': 'मूंग (Mung Bean)',
    'Blackgram': 'उड़द (Black Gram)',
    'Lentil': 'मसूर (Lentil)',
    'Pomegranate': 'अनार (Pomegranate)',
    'Banana': 'केला (Banana)',
    'Mango': 'आम (Mango)',
    'Grapes': 'अंगूर (Grapes)',
    'Watermelon': 'तरबूज (Watermelon)',
    'Muskmelon': 'खरबूजा (Muskmelon)',
    'Apple': 'सेब (Apple)',
    'Orange': 'संतरा (Orange)',
    'Papaya': 'पपीता (Papaya)',
    'Coconut': 'नारियल (Coconut)',
    'Jute': 'पटसन / जूट (Jute)',
    'Coffee': 'कॉफ़ी (Coffee)',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opt = crop.optimalConditions;
    final displayName = _hindiCropNames[crop.cropName] ?? crop.cropName;

    final curN = currentSoil['N'] ?? 80.0;
    final curP = currentSoil['P'] ?? 40.0;
    final curK = currentSoil['K'] ?? 150.0;
    final curPh = currentSoil['pH'] ?? currentSoil['ph'] ?? 6.8;
    final curMoisture = currentSoil['moisture'] ?? currentSoil['Moisture'] ?? 55.0;

    final fertilizerAdvice = _generateFertilizerAdvice(
      n: curN,
      p: curP,
      k: curK,
      ph: curPh,
      opt: opt,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Crop Title & Match Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Season: ${crop.season} • Suitability: ${crop.confidenceLevel}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${crop.suitabilityPercentage}% Match',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Section 1: Soil Nutrient Comparison vs Optimal
            Text(
              'Soil Nutrient Status vs Crop Requirement',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            _buildNutrientRow(
              label: 'Nitrogen (N)',
              current: curN,
              minOpt: opt.minN,
              maxOpt: opt.maxN,
              unit: 'mg/kg',
            ),
            _buildNutrientRow(
              label: 'Phosphorus (P)',
              current: curP,
              minOpt: opt.minP,
              maxOpt: opt.maxP,
              unit: 'mg/kg',
            ),
            _buildNutrientRow(
              label: 'Potassium (K)',
              current: curK,
              minOpt: opt.minK,
              maxOpt: opt.maxK,
              unit: 'mg/kg',
            ),
            _buildNutrientRow(
              label: 'Soil Reaction (pH)',
              current: curPh,
              minOpt: opt.minPh,
              maxOpt: opt.maxPh,
              unit: 'pH',
            ),
            _buildNutrientRow(
              label: 'Root Moisture',
              current: curMoisture,
              minOpt: 40.0,
              maxOpt: 75.0,
              unit: '%',
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Section 2: Targeted Fertilizer & Soil Amendment Plan
            Row(
              children: [
                const Icon(Icons.science, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Recommended Soil Amendment & Fertilizer',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fertilizerAdvice.map((adv) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        Expanded(
                          child: Text(
                            adv,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.teal.shade900,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Section 3: Agronomic Highlights
            if (crop.agronomicHighlights.isNotEmpty) ...[
              Text(
                'Agronomic Sowing Guidelines',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ...crop.agronomicHighlights.map((hl) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hl,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),

            // Close Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Back to Dashboard / वापस जाएं'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow({
    required String label,
    required double current,
    required double minOpt,
    required double maxOpt,
    required String unit,
  }) {
    final isDeficit = current < minOpt;
    final isExcess = current > maxOpt;
    final isOptimal = !isDeficit && !isExcess;

    final statusColor = isOptimal
        ? Colors.green.shade700
        : (isDeficit ? Colors.orange.shade800 : Colors.blue.shade700);

    final statusLabel = isOptimal
        ? 'Optimal (संतुलित)'
        : (isDeficit ? 'Deficit (कमी)' : 'Excess (अधिक)');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${current.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<String> _generateFertilizerAdvice({
    required double n,
    required double p,
    required double k,
    required double ph,
    required CropOptimalConditions opt,
  }) {
    final advice = <String>[];

    if (n < opt.minN) {
      final delta = (opt.minN - n).round();
      advice.add(
        'Nitrogen Deficit (~$delta mg/kg): Apply Urea (46% N) at 30-40 kg/acre in 2 split applications during early tillering.',
      );
    } else if (n > opt.maxN) {
      advice.add(
        'Nitrogen Rich: Hold off additional top-dressed urea to prevent lodging and excessive vegetative growth.',
      );
    } else {
      advice.add('Nitrogen Status: Well-balanced for optimal canopy development.');
    }

    if (p < opt.minP) {
      advice.add(
        'Phosphorus Deficit: Apply Single Super Phosphate (SSP) or DAP at 25 kg/acre as basal dose to stimulate root elongation.',
      );
    }

    if (k < opt.minK) {
      advice.add(
        'Potassium Deficit: Apply Muriate of Potash (MOP) at 20 kg/acre to improve grain firmness and drought resistance.',
      );
    }

    if (ph < opt.minPh) {
      advice.add(
        'Acidic Soil Reaction (pH ${ph.toStringAsFixed(1)}): Broadcast agricultural lime (CaCO3) at 200 kg/acre to optimize nutrient uptake.',
      );
    } else if (ph > opt.maxPh) {
      advice.add(
        'Alkaline Soil Reaction (pH ${ph.toStringAsFixed(1)}): Incorporate agricultural gypsum or farmyard manure (FYM) to lower alkalinity.',
      );
    }

    if (advice.isEmpty) {
      advice.add('Current soil parameters are exceptionally well-balanced for this crop variety.');
    }

    return advice;
  }
}
