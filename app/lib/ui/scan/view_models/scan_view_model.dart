import 'package:flutter/material.dart';
import '../../../core/services/ml_engine_service.dart';

class CropDiseaseDiagnosis {
  final String diseaseName;
  final String diseaseNameHi;
  final double confidence;
  final String severity;
  final String symptoms;
  final String symptomsHi;
  final String treatment;
  final String treatmentHi;
  final Color severityColor;

  const CropDiseaseDiagnosis({
    required this.diseaseName,
    required this.diseaseNameHi,
    required this.confidence,
    required this.severity,
    required this.symptoms,
    required this.symptomsHi,
    required this.treatment,
    required this.treatmentHi,
    required this.severityColor,
  });
}

class ScanViewModel extends ChangeNotifier {
  final MLEngineService _mlEngine;
  bool _isScanning = false;
  String _selectedSample = 'sample_early_blight';
  CropDiseaseDiagnosis? _diagnosis;

  ScanViewModel({MLEngineService? mlEngine})
      : _mlEngine = mlEngine ?? MLEngineService() {
    _diagnosis = _mlEngine.classifyLeafDisease(_selectedSample);
  }

  bool get isScanning => _isScanning;
  String get selectedSample => _selectedSample;
  CropDiseaseDiagnosis? get diagnosis => _diagnosis;

  void selectSample(String sampleKey) {
    _selectedSample = sampleKey;
    _isScanning = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _diagnosis = _mlEngine.classifyLeafDisease(sampleKey);
      _isScanning = false;
      notifyListeners();
    });
  }

  void triggerScan() {
    _isScanning = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 700), () {
      _diagnosis = _mlEngine.classifyLeafDisease(_selectedSample);
      _isScanning = false;
      notifyListeners();
    });
  }
}
