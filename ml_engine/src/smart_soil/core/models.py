"""
Data Models for Soil Telemetry, Validation, and ML Feature Preparation.
Follows Pydantic v2 conventions for strong typing and validation.
"""

from datetime import datetime, timezone
from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field, ConfigDict


class ValidationStatus(str, Enum):
    VALID = "VALID"
    WARNING_OUT_OF_BOUNDS = "WARNING_OUT_OF_BOUNDS"
    INCOMPLETE = "INCOMPLETE"
    CORRUPTED = "CORRUPTED"


class RawSoilReading(BaseModel):
    """Raw payload received from ESP32 or Firebase Firestore document."""
    device_id: str = Field(..., description="Unique ESP32 device identifier (e.g. ESP32-SOIL-01)")
    farmer_id: str = Field(..., description="Farmer identifier linked via Firebase Auth")
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), description="Timestamp of telemetry capture")
    ph: Optional[float] = Field(None, description="Soil pH level (0-14)")
    moisture: Optional[float] = Field(None, description="Soil volumetric moisture percentage (0-100%)")
    nitrogen: Optional[float] = Field(None, description="Soil Nitrogen content (N in mg/kg)")
    phosphorus: Optional[float] = Field(None, description="Soil Phosphorus content (P in mg/kg)")
    potassium: Optional[float] = Field(None, description="Soil Potassium content (K in mg/kg)")
    temperature: Optional[float] = Field(None, description="Ambient / soil temperature in °C from DHT22")
    humidity: Optional[float] = Field(None, description="Ambient relative humidity percentage (0-100%) from DHT22")

    model_config = ConfigDict(extra="ignore")


class FieldValidationResult(BaseModel):
    """Granular validation feedback for a single sensor parameter."""
    field_name: str
    raw_value: Optional[float]
    is_valid: bool
    status: ValidationStatus
    message: str


class ValidationReport(BaseModel):
    """Aggregate validation outcome for a complete telemetry reading."""
    status: ValidationStatus
    is_usable_for_ml: bool
    errors: List[str] = Field(default_factory=list)
    warnings: List[str] = Field(default_factory=list)
    field_reports: Dict[str, FieldValidationResult] = Field(default_factory=dict)
    evaluated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class CleanedSoilFeatures(BaseModel):
    """
    Standardized feature representation aligned with standard crop recommendation models
    (e.g., Kaggle Crop Recommendation: [N, P, K, temperature, humidity, ph, moisture/rainfall]).
    """
    device_id: str
    farmer_id: str
    timestamp: datetime
    nitrogen: float = Field(..., description="Cleaned Nitrogen (N in mg/kg)")
    phosphorus: float = Field(..., description="Cleaned Phosphorus (P in mg/kg)")
    potassium: float = Field(..., description="Cleaned Potassium (K in mg/kg)")
    temperature: float = Field(..., description="Cleaned Temperature (°C)")
    humidity: float = Field(..., description="Cleaned Humidity (%)")
    ph: float = Field(..., description="Cleaned pH")
    moisture: float = Field(..., description="Cleaned Moisture (%)")
    imputed_fields: List[str] = Field(default_factory=list, description="List of fields imputed during preprocessing")

    def to_feature_vector(self) -> List[float]:
        """Returns standard feature vector for scikit-learn / ML model input: [N, P, K, temp, humidity, ph, moisture]."""
        return [
            self.nitrogen,
            self.phosphorus,
            self.potassium,
            self.temperature,
            self.humidity,
            self.ph,
            self.moisture
        ]

    def to_feature_dict(self) -> Dict[str, float]:
        """Returns key-value mapping formatted for downstream AI agent / model reasoning."""
        return {
            "N": self.nitrogen,
            "P": self.phosphorus,
            "K": self.potassium,
            "temperature": self.temperature,
            "humidity": self.humidity,
            "ph": self.ph,
            "moisture": self.moisture
        }
