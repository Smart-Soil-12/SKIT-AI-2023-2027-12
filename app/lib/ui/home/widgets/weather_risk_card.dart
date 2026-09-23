import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';

/// Real-time Weather, Climate & Hindi/English Agricultural Risk Alert Card.
class WeatherRiskCard extends StatelessWidget {
  const WeatherRiskCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = SmartSoilScope.of(context).language;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloudy_snowing,
                    color: Color(0xFF0288D1),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '23.4°C',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: SmartSoilTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: SmartSoilTheme.alertRed.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lang.tr('high_risk'),
                              style: const TextStyle(
                                color: SmartSoilTheme.alertRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Light rain shower • Jaipur, Rajasthan',
                        style: TextStyle(
                          fontSize: 12,
                          color: SmartSoilTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: SmartSoilTheme.creamBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(lang.tr('feels_like'), '25.8°C'),
                  _buildDivider(),
                  _buildStatColumn(lang.tr('humidity'), '91%'),
                  _buildDivider(),
                  _buildStatColumn(lang.tr('rainfall'), '0.52 mm'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB74D), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE65100),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${lang.tr('agri_risk')} • ${lang.tr('high_risk')}',
                        style: const TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.tr('risk_advisory'),
                    style: const TextStyle(
                      color: Color(0xFF5D4037),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.air_rounded,
                  size: 15,
                  color: SmartSoilTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${lang.tr('wind')}: 11.9 km/h • Ambient Soil Monitoring',
                  style: const TextStyle(
                    fontSize: 11,
                    color: SmartSoilTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: SmartSoilTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: SmartSoilTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.black.withOpacity(0.08),
    );
  }
}
