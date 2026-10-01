/// Crop Recommendation Data Structures for Smart Soil
/// Fulfills Form-1 Objective 3 ("Prediction of top 3 crops") and
/// Form-2 Sprint 4 Task ("Prepare Flutter structures to receive & display crop recommendation").
/// Aligns with backend/data/Crop_recommendation.csv and backend/src/encode_crop_labels.py.

class CropOptimalConditions {
  final double minN;
  final double maxN;
  final double minP;
  final double maxP;
  final double minK;
  final double maxK;
  final double minPh;
  final double maxPh;
  final double minTemp;
  final double maxTemp;
  final double minHumidity;
  final double maxHumidity;
  final double minRainfall;
  final double maxRainfall;

  const CropOptimalConditions({
    required this.minN,
    required this.maxN,
    required this.minP,
    required this.maxP,
    required this.minK,
    required this.maxK,
    required this.minPh,
    required this.maxPh,
    required this.minTemp,
    required this.maxTemp,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minRainfall,
    required this.maxRainfall,
  });

  Map<String, dynamic> toJson() => {
        'min_N': minN,
        'max_N': maxN,
        'min_P': minP,
        'max_P': maxP,
        'min_K': minK,
        'max_K': maxK,
        'min_ph': minPh,
        'max_ph': maxPh,
        'min_temp': minTemp,
        'max_temp': maxTemp,
        'min_humidity': minHumidity,
        'max_humidity': maxHumidity,
        'min_rainfall': minRainfall,
        'max_rainfall': maxRainfall,
      };

  factory CropOptimalConditions.fromJson(Map<String, dynamic> json) {
    return CropOptimalConditions(
      minN: (json['min_N'] as num?)?.toDouble() ?? 0.0,
      maxN: (json['max_N'] as num?)?.toDouble() ?? 100.0,
      minP: (json['min_P'] as num?)?.toDouble() ?? 0.0,
      maxP: (json['max_P'] as num?)?.toDouble() ?? 100.0,
      minK: (json['min_K'] as num?)?.toDouble() ?? 0.0,
      maxK: (json['max_K'] as num?)?.toDouble() ?? 100.0,
      minPh: (json['min_ph'] as num?)?.toDouble() ?? 5.5,
      maxPh: (json['max_ph'] as num?)?.toDouble() ?? 7.5,
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 15.0,
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 35.0,
      minHumidity: (json['min_humidity'] as num?)?.toDouble() ?? 30.0,
      maxHumidity: (json['max_humidity'] as num?)?.toDouble() ?? 80.0,
      minRainfall: (json['min_rainfall'] as num?)?.toDouble() ?? 50.0,
      maxRainfall: (json['max_rainfall'] as num?)?.toDouble() ?? 250.0,
    );
  }
}

class CropRecommendationItem {
  final String cropName;
  final double suitabilityScore; // 0.0 to 1.0 (e.g. 0.94 -> 94%)
  final String season; // "Kharif", "Rabi", "Zaid"
  final String confidenceLevel; // "High", "Moderate", "Experimental"
  final List<String> agronomicHighlights;
  final CropOptimalConditions optimalConditions;

  const CropRecommendationItem({
    required this.cropName,
    required this.suitabilityScore,
    required this.season,
    required this.confidenceLevel,
    required this.agronomicHighlights,
    required this.optimalConditions,
  });

  int get suitabilityPercentage => (suitabilityScore * 100).clamp(0, 100).round();

  Map<String, dynamic> toJson() => {
        'crop_name': cropName,
        'suitability_score': suitabilityScore,
        'season': season,
        'confidence_level': confidenceLevel,
        'agronomic_highlights': agronomicHighlights,
        'optimal_conditions': optimalConditions.toJson(),
      };

  factory CropRecommendationItem.fromJson(Map<String, dynamic> json) {
    return CropRecommendationItem(
      cropName: json['crop_name'] as String? ?? 'Unknown Crop',
      suitabilityScore: (json['suitability_score'] as num?)?.toDouble() ?? 0.0,
      season: json['season'] as String? ?? 'General',
      confidenceLevel: json['confidence_level'] as String? ?? 'Moderate',
      agronomicHighlights: (json['agronomic_highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      optimalConditions: json['optimal_conditions'] != null
          ? CropOptimalConditions.fromJson(json['optimal_conditions'] as Map<String, dynamic>)
          : const CropOptimalConditions(
              minN: 50,
              maxN: 120,
              minP: 30,
              maxP: 60,
              minK: 30,
              maxK: 60,
              minPh: 6.0,
              maxPh: 7.5,
              minTemp: 18,
              maxTemp: 32,
              minHumidity: 40,
              maxHumidity: 80,
              minRainfall: 60,
              maxRainfall: 150,
            ),
    );
  }
}

class CropRecommendationResult {
  final String farmerId;
  final DateTime generatedAt;
  final Map<String, double> soilParametersUsed;
  final List<CropRecommendationItem> recommendations;

  const CropRecommendationResult({
    required this.farmerId,
    required this.generatedAt,
    required this.soilParametersUsed,
    required this.recommendations,
  });

  /// Top recommended crop as per Form-1 primary target.
  CropRecommendationItem? get topCrop =>
      recommendations.isNotEmpty ? recommendations.first : null;

  Map<String, dynamic> toJson() => {
        'farmer_id': farmerId,
        'generated_at': generatedAt.toIso8601String(),
        'soil_parameters_used': soilParametersUsed,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
      };

  factory CropRecommendationResult.fromJson(Map<String, dynamic> json) {
    return CropRecommendationResult(
      farmerId: json['farmer_id'] as String? ?? '',
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      soilParametersUsed: (json['soil_parameters_used'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) => CropRecommendationItem.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
