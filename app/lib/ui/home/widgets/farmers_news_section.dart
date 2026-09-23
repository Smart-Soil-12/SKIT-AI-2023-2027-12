import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';

/// Farmers News & Agricultural Advisories Section.
class FarmersNewsSection extends StatelessWidget {
  const FarmersNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = SmartSoilScope.of(context).language;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.tr('farmers_news'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: SmartSoilTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        _buildNewsCard(
          icon: Icons.water_rounded,
          iconColor: const Color(0xFF0288D1),
          title: lang.tr('news_1_title'),
          date: lang.tr('news_1_date'),
        ),
        const SizedBox(height: 8),
        _buildNewsCard(
          icon: Icons.precision_manufacturing_rounded,
          iconColor: SmartSoilTheme.forestGreen,
          title: lang.tr('news_2_title'),
          date: lang.tr('news_2_date'),
        ),
      ],
    );
  }

  Widget _buildNewsCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SmartSoilTheme.textDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: SmartSoilTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: SmartSoilTheme.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
