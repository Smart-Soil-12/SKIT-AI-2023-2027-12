"""
Unit Tests for SoilValidator.
Verifies boundary checks, hardware error sentinels, missing value detection,
and agronomic plausibility rules.
"""

from datetime import datetime, timezone
import pytest
from smart_soil.core.models import RawSoilReading, ValidationStatus
from smart_soil.core.validator import SoilValidator


@pytest.fixture
def validator():
    return SoilValidator(strict_agronomic=False)


@pytest.fixture
def strict_validator():
    return SoilValidator(strict_agronomic=True)


@pytest.fixture
def valid_reading():
    return RawSoilReading(
        device_id="ESP32-SOIL-01",
        farmer_id="farmer_test_101",
        timestamp=datetime.now(timezone.utc),
        nitrogen=90.0,
        phosphorus=42.0,
        potassium=45.0,
        temperature=27.5,
        humidity=65.0,
        ph=6.8,
        moisture=52.0,
    )


def test_nominal_reading_passes_validation(validator, valid_reading):
    report = validator.validate_reading(valid_reading)
    assert report.status == ValidationStatus.VALID
    assert report.is_usable_for_ml is True
    assert len(report.errors) == 0
    assert len(report.warnings) == 0


def test_missing_fields_flagged_incomplete(validator):
    incomplete_reading = RawSoilReading(
        device_id="ESP32-SOIL-01",
        farmer_id="farmer_test_101",
        timestamp=datetime.now(timezone.utc),
        ph=6.5,
        moisture=None,  # Missing
        nitrogen=None,  # Missing
    )
    report = validator.validate_reading(incomplete_reading)
    assert report.is_usable_for_ml is False
    assert "moisture: Field value is missing or NaN" in report.errors
    assert "nitrogen: Field value is missing or NaN" in report.errors


def test_hardware_sentinel_error_detection(validator, valid_reading):
    # Simulate DHT22 disconnect sentinel
    corrupt_reading = valid_reading.model_copy(update={"temperature": -999.0})
    report = validator.validate_reading(corrupt_reading)
    assert report.status == ValidationStatus.CORRUPTED
    assert report.is_usable_for_ml is False
    assert any("Hardware error sentinel detected" in err for err in report.errors)


def test_physical_bounds_enforced(validator, valid_reading):
    # pH cannot physically be 15.0 on standard scale
    invalid_ph_reading = valid_reading.model_copy(update={"ph": 15.0})
    report = validator.validate_reading(invalid_ph_reading)
    assert report.status == ValidationStatus.CORRUPTED
    assert report.is_usable_for_ml is False
    assert any("Physically impossible reading" in err for err in report.errors)


def test_agronomic_boundaries_strict_vs_permissive(validator, strict_validator, valid_reading):
    # Soil pH 2.5 is extremely acidic (physically possible in laboratory/chemicals, but unusual for arable crops)
    acidic_reading = valid_reading.model_copy(update={"ph": 2.5})

    # Permissive validator accepts with warning
    perm_report = validator.validate_reading(acidic_reading)
    assert perm_report.status == ValidationStatus.WARNING_OUT_OF_BOUNDS
    assert perm_report.is_usable_for_ml is True
    assert any("Unusual agronomic value" in w for w in perm_report.warnings)

    # Strict validator rejects
    strict_report = strict_validator.validate_reading(acidic_reading)
    assert strict_report.is_usable_for_ml is False
    assert any("Outside arable soil range" in err for err in strict_report.errors)


def test_batch_validation(validator, valid_reading):
    batch = [valid_reading, valid_reading.model_copy(update={"ph": -1.0})]
    reports = validator.validate_batch(batch)
    assert len(reports) == 2
    assert reports[0].status == ValidationStatus.VALID
    assert reports[1].status == ValidationStatus.CORRUPTED
