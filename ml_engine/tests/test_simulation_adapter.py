"""
Integration Tests for Simulation Engine and Firebase Firestore Adapter.
Verifies end-to-end telemetry pipeline from simulation to cloud format
to ML-ready vectors.
"""

from smart_soil.core.models import ValidationStatus
from smart_soil.core.preprocessor import SoilPreprocessor
from smart_soil.core.validator import SoilValidator
from smart_soil.integration.firebase_adapter import FirebaseAdapter
from smart_soil.simulation.soil_simulator import SoilProfile, SoilSimulator


def test_soil_simulator_profiles():
    sim_fertile = SoilSimulator(profile=SoilProfile.FERTILE_LOAM, seed=42)
    reading_fertile = sim_fertile.generate_reading()
    assert 70.0 <= reading_fertile.nitrogen <= 100.0
    assert 6.0 <= reading_fertile.ph <= 7.2

    sim_arid = SoilSimulator(profile=SoilProfile.ARID_SANDY, seed=42)
    reading_arid = sim_arid.generate_reading()
    assert 10.0 <= reading_arid.nitrogen <= 35.0
    assert 7.0 <= reading_arid.ph <= 8.5


def test_time_series_generation():
    sim = SoilSimulator(seed=123)
    series = sim.generate_time_series(count=12, interval_minutes=30)
    assert len(series) == 12
    # Verify timestamps are sequential
    for i in range(1, 12):
        assert series[i].timestamp > series[i - 1].timestamp


def test_firebase_adapter_nested_roundtrip():
    sim = SoilSimulator(seed=99)
    reading = sim.generate_reading()

    # Convert to Firestore document
    doc = FirebaseAdapter.to_firestore_document(reading, nested=True)
    assert "soil_data" in doc
    assert "env_data" in doc
    assert doc["device_id"] == reading.device_id

    # Verify compatibility
    compatible, issues = FirebaseAdapter.verify_schema_compatibility(doc)
    assert compatible is True
    assert len(issues) == 0

    # Reconstruct from Firestore document
    reconstructed = FirebaseAdapter.from_firestore_document(doc)
    assert reconstructed.device_id == reading.device_id
    assert reconstructed.farmer_id == reading.farmer_id
    assert reconstructed.nitrogen == reading.nitrogen
    assert reconstructed.ph == reading.ph


def test_firebase_adapter_flat_roundtrip():
    sim = SoilSimulator(seed=101)
    reading = sim.generate_reading()

    # Flat Firestore doc
    doc = FirebaseAdapter.to_firestore_document(reading, nested=False)
    assert "nitrogen" in doc
    assert "ph" in doc

    compatible, issues = FirebaseAdapter.verify_schema_compatibility(doc)
    assert compatible is True

    reconstructed = FirebaseAdapter.from_firestore_document(doc)
    assert reconstructed.moisture == reading.moisture


def test_firebase_schema_verification_detects_flaws():
    bad_doc = {
        "device_id": "ESP32-01",
        # missing farmer_id
        "soil_data": {
            "nitrogen": "NOT_A_NUMBER",  # invalid type
            "ph": 6.5
            # missing potassium, phosphorus, moisture
        }
    }
    compatible, issues = FirebaseAdapter.verify_schema_compatibility(bad_doc)
    assert compatible is False
    assert any("farmer" in s for s in issues)
    assert any("numeric" in s for s in issues)


def test_full_pipeline_simulation_to_ml_vector():
    """
    End-to-End:
    1. ESP32 Simulator generates telemetry.
    2. Telemetry serialized to Firebase Firestore document.
    3. Firestore document retrieved and parsed into domain reading.
    4. SoilValidator verifies integrity.
    5. SoilPreprocessor cleans/imputes into ML-ready feature vector.
    """
    sim = SoilSimulator(seed=777)
    raw_simulated = sim.generate_reading()

    # Step 2: Firestore serialization
    doc = FirebaseAdapter.to_firestore_document(raw_simulated)

    # Step 3: Retrieval
    retrieved = FirebaseAdapter.from_firestore_document(doc)

    # Step 4: Validation
    validator = SoilValidator()
    report = validator.validate_reading(retrieved)
    assert report.status in [ValidationStatus.VALID, ValidationStatus.WARNING_OUT_OF_BOUNDS]

    # Step 5: Preprocessing
    preprocessor = SoilPreprocessor(validator=validator)
    ml_features = preprocessor.process(retrieved)

    vector = ml_features.to_feature_vector()
    assert len(vector) == 7
    # All elements must be valid floats
    assert all(isinstance(val, float) for val in vector)
