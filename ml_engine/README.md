# Smart Soil - Precision Agriculture System (Group AI-12)

Smart Soil is an integrated IoT, cloud, weather, and AI/ML-driven precision agriculture platform built for small and medium farmers.

## Module: Soil Data Processing, Simulation & Firebase Adapter
**Owner / Lead Engineer:** Abhinav Sharma (AI/ML & Recommendation System Integration)  
**Timeline:** Sprint 1 (10/08/2026 – 31/08/2026) & Sprint 2 kick-off (24/08/2026 – 30/08/2026)

---

## Directory Layout
```
smart_soil/
├── requirements.txt
├── README.md
├── demo_pipeline.py                  # End-to-end runnable verification demo
├── src/
│   └── smart_soil/
│       ├── __init__.py
│       ├── config/
│       │   ├── __init__.py
│       │   └── sensor_thresholds.py  # Physical sensor ranges, calibration & agronomic bounds
│       ├── core/
│       │   ├── __init__.py
│       │   ├── models.py             # Pydantic schemas (Raw, Validated, Cleaned, Batch)
│       │   ├── validator.py          # SoilValidator: sanity, anomaly & hardware fault detection
│       │   └── preprocessor.py       # SoilPreprocessor: imputation & ML feature vector preparation
│       ├── simulation/
│       │   ├── __init__.py
│       │   └── soil_simulator.py     # Realistic sensor telemetry generator with soil profiles
│       └── integration/
│           ├── __init__.py
│           └── firebase_adapter.py   # Firestore document formatting & schema verification
└── tests/
    ├── __init__.py
    ├── test_validator.py             # Unit tests for validation engine & edge cases
    ├── test_preprocessor.py          # Unit tests for imputation & feature extraction
    └── test_simulation_adapter.py    # Integration tests for simulator & Firebase adapter
```

---

## Cross-Team Interfaces & Dependencies

* **Hardware (Aryan):**
  Sensor ranges in `smart_soil.config.sensor_thresholds` mirror physical hardware limits for ESP32 + Capacitive Moisture + NPK (optical/analog) + pH probe + DHT22.
* **Backend & Cloud (Chetan Singh):**
  `smart_soil.integration.firebase_adapter` provides bi-directional transformation between Firestore documents / FastAPI payload models and the AI/ML pipeline.
* **Frontend Mobile (Chaitanya Sharma):**
  Standard unit definitions (pH, %, mg/kg, °C) are strictly documented in models to guarantee accurate visual representation in the Flutter application.

---

## Running Tests
```powershell
python -m pytest tests/ -v
```

## Running the Demonstration Pipeline
```powershell
python demo_pipeline.py
```
