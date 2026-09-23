import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';

/// Hero "Scan Your Crop" Action Card matching the AgriVision reference.
class HeroCropScannerCard extends StatelessWidget {
  final VoidCallback onOpenScanner;

  const HeroCropScannerCard({
    super.key,
    required this.onOpenScanner,
  });

  @override
  Widget build(BuildContext context) {
    final lang = SmartSoilScope.of(context).language;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SmartSoilTheme.forestGreen, SmartSoilTheme.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SmartSoilTheme.forestGreen.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.eco_rounded,
              size: 110,
              color: Color(0x14FFFFFF),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.tr('scan_your_crop'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lang.tr('scan_subtitle'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onOpenScanner,
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: SmartSoilTheme.forestGreen,
                  ),
                  label: Text(
                    lang.tr('open_camera'),
                    style: const TextStyle(
                      color: SmartSoilTheme.forestGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: SmartSoilTheme.forestGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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
