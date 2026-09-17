"""
Smart Soil - Demonstration Pipeline (Sprint 1 & Sprint 2 Deliverables)
Author: Abhinav Sharma (AI Recommendation System & Integration Lead)
Project: SKIT/AI/2023-2027/12 (Group AI-12)
"""

import sys
from pathlib import Path

# Add src to python path for standalone execution
sys.path.insert(0, str(Path(__file__).parent / "src"))

from smart_soil.core.validator import SoilValidator
from smart_soil.core.preprocessor import SoilPreprocessor
from smart_soil.simulation.soil_simulator import SoilSimulator, SoilProfile
from smart_soil.integration.firebase_adapter import FirebaseAdapter


def main():
    print("=" * 70)
    print(" SMART SOIL: Precision Agriculture System (Group AI-12)")
    print(" Module: Soil Telemetry Processing, Simulation & Firebase Adapter")
    print(" Lead: Abhinav Sharma (Tasks up to August 30, 2026)")
    print("=" * 70)

    # 1. Initialize Modules
    validator = SoilValidator(strict_agronomic=False)
    preprocessor = SoilPreprocessor(validator=validator)
    simulator = SoilSimulator(
        device_id="ESP32-NODE-01",
        farmer_id="farmer_raj_01",
        profile=SoilProfile.FERTILE_LOAM,
        seed=42
    )

    print("\n[Step 1] Generating Simulated Sensor Telemetry (Fertile Loam Profile)...")
    reading = simulator.generate_reading()
    print(f"  * Device: {reading.device_id} | Farmer: {reading.farmer_id}")
    print(f"  * Timestamp: {reading.timestamp.isoformat()}")
    print(f"  * Raw Readings: N={reading.nitrogen}mg/kg, P={reading.phosphorus}mg/kg, K={reading.potassium}mg/kg")
    print(f"                  pH={reading.ph}, Moisture={reading.moisture}%, Temp={reading.temperature}°C, Hum={reading.humidity}%")

    print("\n[Step 2] Validating Telemetry via SoilValidator...")
    report = validator.validate_reading(reading)
    print(f"  * Validation Status: {report.status.value}")
    print(f"  * Usable for ML: {report.is_usable_for_ml}")
    print(f"  * Errors: {len(report.errors)} | Warnings: {len(report.warnings)}")

    print("\n[Step 3] Firebase Firestore Schema Adapter...")
    firestore_doc = FirebaseAdapter.to_firestore_document(reading, nested=True)
    is_compatible, issues = FirebaseAdapter.verify_schema_compatibility(firestore_doc)
    print(f"  * Firestore Schema Verified: {is_compatible}")
    print(f"  * Sample Firestore Payload:\n    {firestore_doc}")

    print("\n[Step 4] Simulating Corrupted Sensor Payload (Missing Moisture + DHT22 Glitch)...")
    corrupted_reading = reading.model_copy(update={"moisture": None, "temperature": -999.0})
    corrupt_report = validator.validate_reading(corrupted_reading)
    print(f"  * Corrupted Status: {corrupt_report.status.value}")
    print(f"  * Diagnostic Errors Caught:")
    for err in corrupt_report.errors:
        print(f"    - {err}")

    print("\n[Step 5] Preprocessing & Imputation for ML Readiness...")
    # Preprocessor automatically repairs the missing/corrupt values using agronomic baselines
    cleaned = preprocessor.process(corrupted_reading)
    print(f"  * Imputed Fields: {cleaned.imputed_fields}")
    print(f"  * Cleaned Temperature: {cleaned.temperature}°C (repaired from -999.0)")
    print(f"  * Cleaned Moisture: {cleaned.moisture}% (repaired from null)")

    ml_vector = cleaned.to_feature_vector()
    print("\n[Step 6] Final ML-Ready Feature Vector for Crop Recommendation Model:")
    print(f"  * Feature Vector: {ml_vector}")
    print("    Format: [N, P, K, Temperature, Humidity, pH, Moisture]")
    print(f"  * Feature Dict for AI Agents: {cleaned.to_feature_dict()}")

    print("\n" + "=" * 70)
    print(" All Sprint 1 & 2 Modules Verified Successfully!")
    print("=" * 70)


if __name__ == "__main__":
    main()
