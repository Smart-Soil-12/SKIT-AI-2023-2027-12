import 'package:flutter/material.dart';
import '../view_models/dashboard_view_model.dart';

/// Interactive alert banner offering actionable agronomic advice based on current sensor parameters.
class AgronomicAlertBanner extends StatelessWidget {
  final DashboardViewModel viewModel;

  const AgronomicAlertBanner({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final statusColor = viewModel.healthStatusColor;
    final isHealthy = viewModel.healthScore >= 80;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHealthy ? Icons.verified_rounded : Icons.warning_amber_rounded,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHealthy ? 'AGRONOMIC ADVISORY' : 'ACTION REQUIRED',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.advisoryMessage,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
