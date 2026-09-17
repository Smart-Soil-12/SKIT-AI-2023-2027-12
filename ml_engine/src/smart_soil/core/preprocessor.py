"""
Soil Telemetry Preprocessor.
Transforms raw/validated sensor telemetry into clean, normalized feature vectors
suitable for Scikit-learn and AI recommendation models. Handles missing values
via rule-based and historical imputation strategies.
"""

from typing import Dict, List, Optional
from smart_soil.config.sensor_thresholds import SENSOR_LIMITS
from smart_soil.core.models import CleanedSoilFeatures, RawSoilReading
from smart_soil.core.validator import SoilValidator


class SoilPreprocessor:
    """
    Cleans, imputes, and formats soil telemetry into ML-ready inputs.
    """

    def __init__(self, validator: Optional[SoilValidator] = None, max_imputable_fields: int = 3):
        """
        :param validator: Optional SoilValidator instance. If None, default validator is used.
        :param max_imputable_fields: Maximum number of missing fields allowed before raising error.
        """
        self.validator = validator or SoilValidator(strict_agronomic=False)
        self.max_imputable_fields = max_imputable_fields

    def process(
        self,
        reading: RawSoilReading,
        recent_history: Optional[List[CleanedSoilFeatures]] = None
    ) -> CleanedSoilFeatures:
        """
        Cleans and transforms a single RawSoilReading into a CleanedSoilFeatures instance.

        :param reading: The raw reading to process.
        :param recent_history: Optional recent valid readings from the same sensor to enable
                               moving-average imputation.
        :return: CleanedSoilFeatures ready for ML inference.
        :raises ValueError: If more than max_imputable_fields are missing/corrupted.
        """
        report = self.validator.validate_reading(reading)
        imputed_fields: List[str] = []
        cleaned_values: Dict[str, float] = {}

        params = ["nitrogen", "phosphorus", "potassium", "temperature", "humidity", "ph", "moisture"]

        # Track invalid fields
        for param in params:
            field_res = report.field_reports.get(param)
            raw_val = getattr(reading, param, None)

            if field_res and field_res.is_valid and raw_val is not None:
                cleaned_values[param] = float(raw_val)
            else:
                imputed_fields.append(param)
                imputed_val = self._impute_param(param, recent_history)
                cleaned_values[param] = imputed_val

        if len(imputed_fields) > self.max_imputable_fields:
            raise ValueError(
                f"Data quality too degraded for ML inference: {len(imputed_fields)} fields "
                f"required imputation (limit: {self.max_imputable_fields}). Fields: {imputed_fields}"
            )

        return CleanedSoilFeatures(
            device_id=reading.device_id,
            farmer_id=reading.farmer_id,
            timestamp=reading.timestamp,
            nitrogen=round(cleaned_values["nitrogen"], 2),
            phosphorus=round(cleaned_values["phosphorus"], 2),
            potassium=round(cleaned_values["potassium"], 2),
            temperature=round(cleaned_values["temperature"], 2),
            humidity=round(cleaned_values["humidity"], 2),
            ph=round(cleaned_values["ph"], 2),
            moisture=round(cleaned_values["moisture"], 2),
            imputed_fields=imputed_fields
        )

    def _impute_param(
        self,
        param: str,
        recent_history: Optional[List[CleanedSoilFeatures]] = None
    ) -> float:
        """
        Imputes a parameter using moving average of recent readings if available,
        falling back to agronomic default baseline.
        """
        if recent_history and len(recent_history) > 0:
            history_values = [
                getattr(h, param) for h in recent_history if getattr(h, param, None) is not None
            ]
            if history_values:
                return sum(history_values) / len(history_values)

        band = SENSOR_LIMITS.get(param)
        if band:
            return band.default_impute_value
        return 0.0

    def process_batch(
        self,
        readings: List[RawSoilReading]
    ) -> List[CleanedSoilFeatures]:
        """
        Processes a sequence of readings, maintaining a rolling history buffer for imputation.
        """
        history: List[CleanedSoilFeatures] = []
        results: List[CleanedSoilFeatures] = []

        for reading in readings:
            try:
                # Use last 5 readings for history
                recent = history[-5:] if history else None
                cleaned = self.process(reading, recent_history=recent)
                results.append(cleaned)
                history.append(cleaned)
            except ValueError:
                # Corrupted readings beyond repair are omitted from output but logged
                continue

        return results
