import 'package:flutter/material.dart';
import '../../../data/models/crop_recommendation_model.dart';

/// Top-3 Crop Recommendation UI Component for Smart Soil
/// Fulfills Form-1 Objective 3 & Form-2 Sprint 4 / Sprint 5 Task:
/// "Prepare Flutter response structure for top-3 crop & verified output fields for API integration & recommendation display."
class CropRecommendationCard extends StatelessWidget {
  final CropRecommendationResult recommendationResult;
  final VoidCallback? onRefresh;

  const CropRecommendationCard({
    super.key,
    required this.recommendationResult,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topCrops = recommendationResult.recommendations.take(3).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco, color: Colors.green, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Crop Recommendations',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'AI-Driven Field Suitability',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Recalculate Recommendations',
                    onPressed: onRefresh,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (topCrops.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No crop recommendations available for current telemetry.'),
                ),
              )
            else
              ...List.generate(topCrops.length, (index) {
                final crop = topCrops[index];
                return _buildCropRankTile(context, crop, index + 1);
              }),
            const Divider(height: 24),
            _buildTelemetrySummaryFootnote(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCropRankTile(BuildContext context, CropRecommendationItem crop, int rank) {
    final isTopRank = rank == 1;
    final primaryColor = isTopRank ? Colors.green.shade700 : Colors.blueGrey.shade700;
    final badgeColor = isTopRank ? Colors.green.shade100 : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTopRank ? Colors.green.shade50.withOpacity(0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopRank ? Colors.green.shade300 : Colors.grey.shade300,
          width: isTopRank ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      'Season: ${crop.season} • Confidence: ${crop.confidenceLevel}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isTopRank ? Colors.green.shade600 : Colors.blueGrey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${crop.suitabilityPercentage}% Match',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: crop.suitabilityScore.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isTopRank ? Colors.green.shade600 : Colors.blueGrey.shade500,
              ),
              minHeight: 6,
            ),
          ),
          if (crop.agronomicHighlights.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              crop.agronomicHighlights.first,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetrySummaryFootnote(BuildContext context) {
    final params = recommendationResult.soilParametersUsed;
    final n = params['N']?.toStringAsFixed(0) ?? '--';
    final p = params['P']?.toStringAsFixed(0) ?? '--';
    final k = params['K']?.toStringAsFixed(0) ?? '--';
    final ph = params['pH']?.toStringAsFixed(1) ?? '--';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Soil Baseline: N:$n P:$p K:$k | pH:$ph',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          'Target: High Harvest Yield',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}
