/// Constants defining physical measurement ranges, optimal agronomic thresholds,
/// and display units for soil parameters.
class SoilThresholds {
  SoilThresholds._();

  // --- Display Units ---
  static const String unitPh = 'pH';
  static const String unitMoisture = '%';
  static const String unitNitrogen = 'mg/kg';
  static const String unitPhosphorus = 'mg/kg';
  static const String unitPotassium = 'mg/kg';
  static const String unitTemperature = '°C';
  static const String unitHumidity = '%';

  // --- pH Boundaries ---
  static const double minPh = 0.0;
  static const double maxPh = 14.0;
  static const double phStronglyAcidic = 5.5;
  static const double phOptimalMin = 6.0;
  static const double phOptimalMax = 7.5;
  static const double phStronglyAlkaline = 8.5;

  // --- Soil Moisture Boundaries (%) ---
  static const double minMoisture = 0.0;
  static const double maxMoisture = 100.0;
  static const double moistureCriticalDry = 20.0;
  static const double moistureOptimalMin = 40.0;
  static const double moistureOptimalMax = 70.0;
  static const double moistureWaterlogged = 85.0;

  // --- Nitrogen (N) Boundaries (mg/kg) ---
  static const double minNitrogen = 0.0;
  static const double maxNitrogen = 500.0;
  static const double nitrogenLow = 50.0;
  static const double nitrogenOptimalMin = 50.0;
  static const double nitrogenOptimalMax = 140.0;
  static const double nitrogenExcess = 200.0;

  // --- Phosphorus (P) Boundaries (mg/kg) ---
  static const double minPhosphorus = 0.0;
  static const double maxPhosphorus = 300.0;
  static const double phosphorusLow = 20.0;
  static const double phosphorusOptimalMin = 20.0;
  static const double phosphorusOptimalMax = 50.0;
  static const double phosphorusExcess = 80.0;

  // --- Potassium (K) Boundaries (mg/kg) ---
  static const double minPotassium = 0.0;
  static const double maxPotassium = 600.0;
  static const double potassiumLow = 100.0;
  static const double potassiumOptimalMin = 100.0;
  static const double potassiumOptimalMax = 250.0;
  static const double potassiumExcess = 350.0;

  // --- Temperature Boundaries (°C) ---
  static const double minTemperature = -10.0;
  static const double maxTemperature = 60.0;
  static const double tempFrostWarning = 10.0;
  static const double tempOptimalMin = 18.0;
  static const double tempOptimalMax = 30.0;
  static const double tempHeatStress = 35.0;

  // --- Relative Humidity Boundaries (%) ---
  static const double minHumidity = 0.0;
  static const double maxHumidity = 100.0;
  static const double humidityLow = 30.0;
  static const double humidityOptimalMin = 40.0;
  static const double humidityOptimalMax = 75.0;
  static const double humidityHigh = 85.0;
}
