"""
Firebase Firestore Schema Adapter.
Bridges raw IoT telemetry, Chetan's Firebase Firestore document formats,
and the downstream AI/ML recommendation inputs.
"""

from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple
from smart_soil.core.models import RawSoilReading


class FirebaseAdapter:
    """
    Handles translation and verification of Firestore document payloads to/from
    Smart Soil domain models.
    """

    @staticmethod
    def to_firestore_document(
        reading: RawSoilReading,
        nested: bool = True
    ) -> Dict[str, Any]:
        """
        Converts a RawSoilReading into a Firestore-compliant document dictionary.

        :param reading: Domain model instance.
        :param nested: If True, uses modular nested objects ('soil_data', 'env_data')
                       commonly used in Firestore architecture. If False, produces flattened structure.
        """
        iso_timestamp = reading.timestamp.isoformat()

        if nested:
            return {
                "device_id": reading.device_id,
                "farmer_id": reading.farmer_id,
                "timestamp": iso_timestamp,
                "soil_data": {
                    "nitrogen": reading.nitrogen,
                    "phosphorus": reading.phosphorus,
                    "potassium": reading.potassium,
                    "ph": reading.ph,
                    "moisture": reading.moisture,
                },
                "env_data": {
                    "temperature": reading.temperature,
                    "humidity": reading.humidity,
                },
                "_meta": {
                    "adapter_version": "1.0",
                    "source": "smart_soil_iot_pipeline"
                }
            }
        else:
            return {
                "device_id": reading.device_id,
                "farmer_id": reading.farmer_id,
                "timestamp": iso_timestamp,
                "nitrogen": reading.nitrogen,
                "phosphorus": reading.phosphorus,
                "potassium": reading.potassium,
                "ph": reading.ph,
                "moisture": reading.moisture,
                "temperature": reading.temperature,
                "humidity": reading.humidity,
            }

    @staticmethod
    def from_firestore_document(doc: Dict[str, Any]) -> RawSoilReading:
        """
        Parses a document retrieved from Firebase Firestore into a RawSoilReading.
        Handles both nested and flattened document layouts automatically.
        """
        device_id = doc.get("device_id") or doc.get("deviceId", "UNKNOWN_DEVICE")
        farmer_id = doc.get("farmer_id") or doc.get("farmerId", "UNKNOWN_FARMER")

        # Parse timestamp
        raw_ts = doc.get("timestamp")
        if isinstance(raw_ts, datetime):
            ts = raw_ts
        elif isinstance(raw_ts, str):
            try:
                ts = datetime.fromisoformat(raw_ts.replace("Z", "+00:00"))
            except ValueError:
                ts = datetime.now(timezone.utc)
        elif isinstance(raw_ts, (int, float)):
            # Epoch milliseconds or seconds
            ts_val = raw_ts / 1000.0 if raw_ts > 1e11 else float(raw_ts)
            ts = datetime.fromtimestamp(ts_val, tz=timezone.utc)
        else:
            ts = datetime.now(timezone.utc)

        # Handle nested vs flat
        if "soil_data" in doc or "env_data" in doc:
            soil = doc.get("soil_data", {})
            env = doc.get("env_data", {})
            return RawSoilReading(
                device_id=device_id,
                farmer_id=farmer_id,
                timestamp=ts,
                nitrogen=soil.get("nitrogen") or soil.get("n"),
                phosphorus=soil.get("phosphorus") or soil.get("p"),
                potassium=soil.get("potassium") or soil.get("k"),
                ph=soil.get("ph"),
                moisture=soil.get("moisture"),
                temperature=env.get("temperature") or env.get("temp"),
                humidity=env.get("humidity"),
            )
        else:
            return RawSoilReading(
                device_id=device_id,
                farmer_id=farmer_id,
                timestamp=ts,
                nitrogen=doc.get("nitrogen") or doc.get("n"),
                phosphorus=doc.get("phosphorus") or doc.get("p"),
                potassium=doc.get("potassium") or doc.get("k"),
                ph=doc.get("ph"),
                moisture=doc.get("moisture"),
                temperature=doc.get("temperature") or doc.get("temp"),
                humidity=doc.get("humidity"),
            )

    @staticmethod
    def verify_schema_compatibility(doc: Dict[str, Any]) -> Tuple[bool, List[str]]:
        """
        Verifies that a Firestore document matches the required contract for the
        recommendation engine.
        Returns (is_compatible, list_of_issues).
        """
        issues: List[str] = []

        if not isinstance(doc, dict):
            return False, ["Payload is not a valid JSON/Dict structure"]

        if not doc.get("device_id") and not doc.get("deviceId"):
            issues.append("Missing device identifier field ('device_id' or 'deviceId')")

        if not doc.get("farmer_id") and not doc.get("farmerId"):
            issues.append("Missing farmer identifier field ('farmer_id' or 'farmerId')")

        is_nested = "soil_data" in doc or "env_data" in doc
        required_fields = ["nitrogen", "phosphorus", "potassium", "ph", "moisture", "temperature", "humidity"]

        for f in required_fields:
            if is_nested:
                if f in ["temperature", "humidity"]:
                    container = doc.get("env_data", {})
                else:
                    container = doc.get("soil_data", {})
                val = container.get(f)
            else:
                val = doc.get(f)

            if val is None:
                issues.append(f"Missing parameter in Firestore doc: '{f}'")
            elif not isinstance(val, (int, float)):
                issues.append(f"Field '{f}' is not numeric (type: {type(val).__name__})")

        return (len(issues) == 0, issues)
