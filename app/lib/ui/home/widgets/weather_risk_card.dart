import 'package:flutter/material.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/state/smart_soil_scope.dart';
import '../../../data/models/weather_forecast_model.dart';
import '../../core/app_theme.dart';

/// Real-time Weather, Climate & Hindi/English Agricultural Risk Alert Card.
/// Reactively bound to `WeatherViewModel` (`/api/weather/current`).
class WeatherRiskCard extends StatelessWidget {
  const WeatherRiskCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = SmartSoilScope.of(context);
    final lang = scope.language;
    final weatherVm = scope.weather;
    final forecast = weatherVm.forecast;

    final riskBadge = _riskStyling(forecast.riskLevel, lang);

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
                  child: Icon(
                    forecast.rainfall >= 15
                        ? Icons.thunderstorm_rounded
                        : Icons.cloudy_snowing,
                    color: const Color(0xFF0288D1),
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
                          Text(
                            '${forecast.temperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: SmartSoilTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: riskBadge.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              riskBadge.label,
                              style: TextStyle(
                                color: riskBadge.color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${forecast.conditionSummary} • ${forecast.locationName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: SmartSoilTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: weatherVm.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 20),
                  tooltip: lang.tr('live_weather'),
                  onPressed: weatherVm.isLoading
                      ? null
                      : () => weatherVm.loadWeather(),
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
                  _buildStatColumn(
                    lang.tr('feels_like'),
                    '${forecast.feelsLikeC.toStringAsFixed(1)}°C',
                  ),
                  _buildDivider(),
                  _buildStatColumn(
                    lang.tr('humidity'),
                    '${forecast.humidity.round()}%',
                  ),
                  _buildDivider(),
                  _buildStatColumn(
                    lang.tr('rainfall'),
                    '${forecast.rainfall.toStringAsFixed(2)} mm',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: riskBadge.bannerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: riskBadge.bannerBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: riskBadge.bannerText,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${lang.tr('agri_risk')} • ${riskBadge.label}',
                        style: TextStyle(
                          color: riskBadge.bannerText,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    riskBadge.advisory,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.air_rounded,
                      size: 15,
                      color: SmartSoilTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${lang.tr('wind')}: ${forecast.windSpeedKmh.toStringAsFixed(1)} km/h',
                      style: const TextStyle(
                        fontSize: 11,
                        color: SmartSoilTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (weatherVm.isBackendOnline
                            ? Colors.green
                            : Colors.blueGrey)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    weatherVm.isBackendOnline
                        ? lang.tr('live_api')
                        : lang.tr('offline_cached'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: weatherVm.isBackendOnline
                          ? Colors.green.shade800
                          : Colors.blueGrey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _RiskVisual _riskStyling(WeatherRiskLevel level, LanguageProvider lang) {
    switch (level) {
      case WeatherRiskLevel.high:
        return _RiskVisual(
          color: SmartSoilTheme.alertRed,
          label: lang.tr('high_risk'),
          advisory: lang.tr('risk_advisory'),
          bannerBg: const Color(0xFFFFF3E0),
          bannerBorder: const Color(0xFFFFB74D),
          bannerText: const Color(0xFFE65100),
        );
      case WeatherRiskLevel.moderate:
        return _RiskVisual(
          color: const Color(0xFFEF6C00),
          label: lang.tr('moderate_risk'),
          advisory: lang.tr('moderate_advisory'),
          bannerBg: const Color(0xFFFFF8E1),
          bannerBorder: const Color(0xFFFFD54F),
          bannerText: const Color(0xFFF57C00),
        );
      case WeatherRiskLevel.low:
        return _RiskVisual(
          color: Colors.green.shade700,
          label: lang.tr('low_risk'),
          advisory: lang.tr('low_advisory'),
          bannerBg: const Color(0xFFE8F5E9),
          bannerBorder: const Color(0xFF81C784),
          bannerText: const Color(0xFF2E7D32),
        );
    }
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

class _RiskVisual {
  final Color color;
  final String label;
  final String advisory;
  final Color bannerBg;
  final Color bannerBorder;
  final Color bannerText;

  const _RiskVisual({
    required this.color,
    required this.label,
    required this.advisory,
    required this.bannerBg,
    required this.bannerBorder,
    required this.bannerText,
  });
}
