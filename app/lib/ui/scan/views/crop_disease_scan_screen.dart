import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../../core/state/smart_soil_scope.dart';
import '../view_models/scan_view_model.dart';

/// Dedicated AI Crop Disease Scanner Screen.
class CropDiseaseScanScreen extends StatelessWidget {
  const CropDiseaseScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = SmartSoilScope.of(context);
    final lang = scope.language;
    final scanVm = scope.scan;
    final diagnosis = scanVm.diagnosis;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          lang.tr('scan_title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: SmartSoilTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 170,
                height: 140,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: scanVm.isScanning
                        ? SmartSoilTheme.mintAccent
                        : Colors.white.withOpacity(0.6),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: scanVm.isScanning
                    ? const Center(
                        child: CircularProgressIndicator(color: SmartSoilTheme.mintAccent),
                      )
                    : Icon(
                        Icons.filter_center_focus_rounded,
                        size: 48,
                        color: Colors.white.withOpacity(0.4),
                      ),
              ),
              Positioned(
                bottom: 12,
                child: Text(
                  lang.tr('scan_instructions'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          lang.tr('select_sample_leaf'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: SmartSoilTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSampleChip(scanVm, 'sample_early_blight', lang.tr('sample_early_blight')),
              const SizedBox(width: 8),
              _buildSampleChip(scanVm, 'sample_healthy', lang.tr('sample_healthy')),
              const SizedBox(width: 8),
              _buildSampleChip(scanVm, 'sample_late_blight', lang.tr('sample_late_blight')),
              const SizedBox(width: 8),
              _buildSampleChip(scanVm, 'sample_curl', lang.tr('sample_curl')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (diagnosis != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang.tr('diagnosis_result'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: SmartSoilTheme.textMuted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: diagnosis.severityColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          diagnosis.severity,
                          style: TextStyle(
                            color: diagnosis.severityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lang.isHindi ? diagnosis.diseaseNameHi : diagnosis.diseaseName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: SmartSoilTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${lang.tr('confidence')}: ${diagnosis.confidence.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: SmartSoilTheme.forestGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: diagnosis.confidence / 100,
                            backgroundColor: Colors.black.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation(SmartSoilTheme.forestGreen),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    lang.tr('symptoms'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: SmartSoilTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang.isHindi ? diagnosis.symptomsHi : diagnosis.symptoms,
                    style: const TextStyle(
                      fontSize: 12,
                      color: SmartSoilTheme.textMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SmartSoilTheme.forestGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SmartSoilTheme.forestGreen.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.healing_rounded, size: 16, color: SmartSoilTheme.forestGreen),
                            const SizedBox(width: 6),
                            Text(
                              lang.tr('recommended_treatment'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: SmartSoilTheme.forestGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lang.isHindi ? diagnosis.treatmentHi : diagnosis.treatment,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SmartSoilTheme.textDark,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSampleChip(
    ScanViewModel vm,
    String key,
    String label,
  ) {
    final isSelected = vm.selectedSample == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.selectSample(key),
      selectedColor: SmartSoilTheme.forestGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : SmartSoilTheme.textDark,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
    );
  }
}
