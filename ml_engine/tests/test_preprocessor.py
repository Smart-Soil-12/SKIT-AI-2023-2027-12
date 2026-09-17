"""
Unit Tests for SoilPreprocessor.
Verifies imputation logic, rolling history calculation, and ML feature vector extraction.
"""

from datetime import datetime, timezone
import pytest
from smart_soil.config.sensor_thresholds import SENSOR_LIMITS
from smart_soil.core.models import CleanedSoilFeatures, RawSoilReading
from smart_soil.core.preprocessor import SoilPreprocessor


@pytest.fixture
def preprocessor():
    return SoilPreprocessor()


@pytest.fixture
def clean_raw():
    return RawSoilReading(
        device_id="ESP32-SOIL-01",
        farmer_id="farmer_test_101",
        timestamp=datetime.now(timezone.utc),
        nitrogen=75.0,
        phosphorus=35.0,
        potassium=40.0,
        temperature=28.0,
        humidity=70.0,
        ph=6.5,
        moisture=45.0,
    )


def test_clean_reading_feature_vector(preprocessor, clean_raw):
    cleaned = preprocessor.process(clean_raw)
    assert isinstance(cleaned, CleanedSoilFeatures)
    assert cleaned.imputed_fields == []
    
    vec = cleaned.to_feature_vector()
    assert len(vec) == 7
    assert vec == [75.0, 35.0, 40.0, 28.0, 70.0, 6.5, 45.0]

    feature_dict = cleaned.to_feature_dict()
    assert feature_dict["N"] == 75.0
    assert feature_dict["moisture"] == 45.0


def test_missing_single_field_imputation_fallback(preprocessor, clean_raw):
    # Moisture is missing
    raw_missing = clean_raw.model_copy(update={"moisture": None})
    cleaned = preprocessor.process(raw_missing)

    assert "moisture" in cleaned.imputed_fields
    # Expected fallback default for moisture is 45.0
    assert cleaned.moisture == SENSOR_LIMITS["moisture"].default_impute_value


def test_history_based_moving_average_imputation(preprocessor, clean_raw):
    # Create two historical readings with nitrogen = 80 and 90 (average = 85)
    hist1 = preprocessor.process(clean_raw.model_copy(update={"nitrogen": 80.0}))
    hist2 = preprocessor.process(clean_raw.model_copy(update={"nitrogen": 90.0}))

    # Current reading has null nitrogen
    current_raw = clean_raw.model_copy(update={"nitrogen": None})
    cleaned = preprocessor.process(current_raw, recent_history=[hist1, hist2])

    assert "nitrogen" in cleaned.imputed_fields
    assert cleaned.nitrogen == 85.0


def test_excessive_missing_fields_raises_error(preprocessor, clean_raw):
    # Missing 4 fields (limit is 3)
    severely_degraded = clean_raw.model_copy(
        update={"nitrogen": None, "phosphorus": None, "potassium": None, "ph": None}
    )
    with pytest.raises(ValueError, match="Data quality too degraded for ML inference"):
        preprocessor.process(severely_degraded)


def test_process_batch_filtering(preprocessor, clean_raw):
    # 1 valid, 1 with 1 missing (imputable), 1 severely corrupted
    r1 = clean_raw
    r2 = clean_raw.model_copy(update={"ph": None})
    r3 = clean_raw.model_copy(
        update={"nitrogen": None, "phosphorus": None, "potassium": None, "ph": None, "moisture": None}
    )

    results = preprocessor.process_batch([r1, r2, r3])
    # r3 should be filtered out, r1 and r2 processed
    assert len(results) == 2
    assert results[0].imputed_fields == []
    assert "ph" in results[1].imputed_fields
