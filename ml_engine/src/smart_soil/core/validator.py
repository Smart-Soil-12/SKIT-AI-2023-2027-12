"""
Soil Telemetry Validation Engine.
Performs data integrity verification, physical boundary checking,
agronomic plausibility checks, and hardware fault detection.
"""

import math
from typing import Dict, List, Optional
from smart_soil.config.sensor_thresholds import SENSOR_LIMITS, SensorThresholds
from smart_soil.core.models import (
    FieldValidationResult,
    RawSoilReading,
    ValidationReport,
    ValidationStatus,
)


class SoilValidator:
    """
    Validates soil sensor telemetry against physical and agronomic thresholds.
    """

    # Known hardware error sentinel values (e.g., disconnected DHT22 / ADC overflow)
    HARDWARE_ERROR_SENTINELS = {-999.0, -127.0, 999.0, 4095.0, 1023.0}

    def __init__(self, strict_agronomic: bool = False):
        """
        :param strict_agronomic: If True, values outside acceptable agricultural
                                 ranges are marked invalid. If False, they trigger
                                 warnings but are kept if physically possible.
        """
        self.strict_agronomic = strict_agronomic

    def validate_reading(self, reading: RawSoilReading) -> ValidationReport:
        """Evaluates a single raw reading and produces a comprehensive diagnostic report."""
        field_reports: Dict[str, FieldValidationResult] = {}
        errors: List[str] = []
        warnings: List[str] = []

        params = ["ph", "moisture", "nitrogen", "phosphorus", "potassium", "temperature", "humidity"]

        for param in params:
            val = getattr(reading, param, None)
            field_res = self._validate_field(param, val)
            field_reports[param] = field_res

            if not field_res.is_valid:
                errors.append(f"{param}: {field_res.message}")
            elif field_res.status == ValidationStatus.WARNING_OUT_OF_BOUNDS:
                warnings.append(f"{param}: {field_res.message}")

        # Determine overall aggregate status
        if errors:
            # Check if all fields are missing
            missing_count = sum(1 for p in params if getattr(reading, p, None) is None)
            if missing_count == len(params):
                status = ValidationStatus.INCOMPLETE
            else:
                status = ValidationStatus.CORRUPTED
            is_usable = False
        elif warnings:
            status = ValidationStatus.WARNING_OUT_OF_BOUNDS
            is_usable = True
        else:
            status = ValidationStatus.VALID
            is_usable = True

        return ValidationReport(
            status=status,
            is_usable_for_ml=is_usable,
            errors=errors,
            warnings=warnings,
            field_reports=field_reports,
        )

    def _validate_field(self, param: str, val: Optional[float]) -> FieldValidationResult:
        band = SensorThresholds.get_band(param)

        # 1. Check for Missing / Null
        if val is None or (isinstance(val, float) and math.isnan(val)):
            return FieldValidationResult(
                field_name=param,
                raw_value=val,
                is_valid=False,
                status=ValidationStatus.INCOMPLETE,
                message="Field value is missing or NaN",
            )

        # 2. Check for Hardware Sentinel Errors
        if val in self.HARDWARE_ERROR_SENTINELS:
            return FieldValidationResult(
                field_name=param,
                raw_value=val,
                is_valid=False,
                status=ValidationStatus.CORRUPTED,
                message=f"Hardware error sentinel detected: {val}",
            )

        # 3. Check Physical Feasibility
        if not (band.sensor_min <= val <= band.sensor_max):
            return FieldValidationResult(
                field_name=param,
                raw_value=val,
                is_valid=False,
                status=ValidationStatus.CORRUPTED,
                message=f"Physically impossible reading: {val} {band.unit} (expected [{band.sensor_min}, {band.sensor_max}])",
            )

        # 4. Check Agronomic Plausibility
        if not (band.agronomic_min <= val <= band.agronomic_max):
            if self.strict_agronomic:
                return FieldValidationResult(
                    field_name=param,
                    raw_value=val,
                    is_valid=False,
                    status=ValidationStatus.WARNING_OUT_OF_BOUNDS,
                    message=f"Outside arable soil range: {val} {band.unit} (bounds: [{band.agronomic_min}, {band.agronomic_max}])",
                )
            else:
                return FieldValidationResult(
                    field_name=param,
                    raw_value=val,
                    is_valid=True,
                    status=ValidationStatus.WARNING_OUT_OF_BOUNDS,
                    message=f"Unusual agronomic value: {val} {band.unit} (typical arable: [{band.agronomic_min}, {band.agronomic_max}])",
                )

        return FieldValidationResult(
            field_name=param,
            raw_value=val,
            is_valid=True,
            status=ValidationStatus.VALID,
            message="Optimal and valid",
        )

    def validate_batch(self, readings: List[RawSoilReading]) -> List[ValidationReport]:
        """Validates a collection of telemetry readings."""
        return [self.validate_reading(r) for r in readings]
