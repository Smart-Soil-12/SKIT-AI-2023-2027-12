"""
Hardware Sensor Specifications and Agronomic Thresholds.
Reflects physical sensor limits (ESP32 + NPK + pH + Moisture + DHT22)
coordinated with Team Lead (Aryan) and Backend (Chetan Singh).
"""

from dataclasses import dataclass
from typing import Dict, Tuple


@dataclass(frozen=True)
class ThresholdBand:
    """Range bounds for physical sensor output and acceptable agronomic limits."""
    sensor_min: float
    sensor_max: float
    agronomic_min: float
    agronomic_max: float
    unit: str
    default_impute_value: float


# Sensor limits and validation thresholds
SENSOR_LIMITS: Dict[str, ThresholdBand] = {
    "ph": ThresholdBand(
        sensor_min=0.0,
        sensor_max=14.0,
        agronomic_min=3.5,
        agronomic_max=9.5,
        unit="pH",
        default_impute_value=6.5
    ),
    "moisture": ThresholdBand(
        sensor_min=0.0,
        sensor_max=100.0,
        agronomic_min=5.0,
        agronomic_max=95.0,
        unit="%",
        default_impute_value=45.0
    ),
    "nitrogen": ThresholdBand(
        sensor_min=0.0,
        sensor_max=500.0,
        agronomic_min=0.0,
        agronomic_max=300.0,
        unit="mg/kg",
        default_impute_value=50.0
    ),
    "phosphorus": ThresholdBand(
        sensor_min=0.0,
        sensor_max=400.0,
        agronomic_min=0.0,
        agronomic_max=200.0,
        unit="mg/kg",
        default_impute_value=35.0
    ),
    "potassium": ThresholdBand(
        sensor_min=0.0,
        sensor_max=500.0,
        agronomic_min=0.0,
        agronomic_max=350.0,
        unit="mg/kg",
        default_impute_value=40.0
    ),
    "temperature": ThresholdBand(
        sensor_min=-10.0,
        sensor_max=60.0,
        agronomic_min=5.0,
        agronomic_max=50.0,
        unit="°C",
        default_impute_value=26.0
    ),
    "humidity": ThresholdBand(
        sensor_min=0.0,
        sensor_max=100.0,
        agronomic_min=10.0,
        agronomic_max=100.0,
        unit="%",
        default_impute_value=60.0
    ),
}


class SensorThresholds:
    """Helper methods for boundary checking."""

    @staticmethod
    def get_band(param: str) -> ThresholdBand:
        if param not in SENSOR_LIMITS:
            raise KeyError(f"Unknown sensor parameter: {param}")
        return SENSOR_LIMITS[param]

    @staticmethod
    def is_physically_possible(param: str, value: float) -> bool:
        """Checks whether the raw reading is within physical sensor capability."""
        band = SensorThresholds.get_band(param)
        return band.sensor_min <= value <= band.sensor_max

    @staticmethod
    def is_agronomically_valid(param: str, value: float) -> bool:
        """Checks whether the reading makes sense for agricultural cultivation."""
        band = SensorThresholds.get_band(param)
        return band.agronomic_min <= value <= band.agronomic_max
