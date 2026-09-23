import 'package:flutter/material.dart';
import '../../../domain/models/soil_reading.dart';
import '../../../core/services/ml_engine_service.dart';

class YieldViewModel extends ChangeNotifier {
  final MLEngineService _mlEngine;
  String _selectedCrop = 'Wheat (गेहूं)';
  double _farmSizeAcres = 5.0;

  final List<String> crops = [
    'Wheat (गेहूं)',
    'Rice / Paddy (धान)',
    'Cotton (कपास)',
    'Maize (मक्का)',
    'Mustard (सरसों)',
  ];

  YieldViewModel({MLEngineService? mlEngine})
      : _mlEngine = mlEngine ?? MLEngineService();

  String get selectedCrop => _selectedCrop;
  double get farmSizeAcres => _farmSizeAcres;

  void setCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  void setFarmSize(double acres) {
    _farmSizeAcres = acres;
    notifyListeners();
  }

  double calculateYieldPerAcre(SoilReading reading) {
    return _mlEngine.calculatePredictedYield(
      crop: _selectedCrop,
      farmSizeAcres: _farmSizeAcres,
      reading: reading,
    );
  }

  double calculateTotalHarvest(SoilReading reading) {
    final perAcre = calculateYieldPerAcre(reading);
    return double.parse((perAcre * _farmSizeAcres).toStringAsFixed(1));
  }
}
