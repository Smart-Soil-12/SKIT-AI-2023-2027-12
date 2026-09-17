"""
Synthetic Soil Telemetry Generator (SoilSimulator).
Simulates realistic ESP32 sensor streams with hardware noise,
diurnal environmental cycles, and agricultural soil profiles.
Supports Sprint 2 simulation & pipeline testing.
"""

import math
import random
from datetime import datetime, timedelta, timezone
from enum import Enum
from typing import Dict, List, Optional
from smart_soil.core.models import RawSoilReading


class SoilProfile(str, Enum):
    FERTILE_LOAM = "FERTILE_LOAM"
    ARID_SANDY = "ARID_SANDY"
    ACIDIC_CLAY = "ACIDIC_CLAY"
    DEGRADED = "DEGRADED"


# Mean baseline values per profile: (N, P, K, pH, Moisture)
PROFILE_BASELINES: Dict[SoilProfile, Dict[str, float]] = {
    SoilProfile.FERTILE_LOAM: {
        "nitrogen": 85.0,
        "phosphorus": 45.0,
        "potassium": 48.0,
        "ph": 6.6,
        "moisture": 55.0,
    },
    SoilProfile.ARID_SANDY: {
        "nitrogen": 22.0,
        "phosphorus": 14.0,
        "potassium": 25.0,
        "ph": 7.9,
        "moisture": 18.0,
    },
    SoilProfile.ACIDIC_CLAY: {
        "nitrogen": 48.0,
        "phosphorus": 30.0,
        "potassium": 40.0,
        "ph": 4.9,
        "moisture": 68.0,
    },
    SoilProfile.DEGRADED: {
        "nitrogen": 10.0,
        "phosphorus": 6.0,
        "potassium": 12.0,
        "ph": 8.8,
        "moisture": 12.0,
    },
}


class SoilSimulator:
    """
    Generates synthetic ESP32 sensor telemetry for testing downstream
    data processing, Firebase storage, and ML models.
    """

    def __init__(
        self,
        device_id: str = "ESP32-SOIL-01",
        farmer_id: str = "farmer_101",
        profile: SoilProfile = SoilProfile.FERTILE_LOAM,
        seed: Optional[int] = None,
    ):
        self.device_id = device_id
        self.farmer_id = farmer_id
        self.profile = profile
        if seed is not None:
            random.seed(seed)

    def generate_reading(
        self,
        timestamp: Optional[datetime] = None,
        inject_noise: bool = True,
        inject_anomaly: bool = False,
    ) -> RawSoilReading:
        """
        Generates a single telemetry reading reflecting current environmental time.
        """
        ts = timestamp or datetime.now(timezone.utc)
        baseline = PROFILE_BASELINES[self.profile]

        # Diurnal temperature cycle: peak around 14:00 (2 PM), low around 04:00 (4 AM)
        hour = ts.hour + ts.minute / 60.0
        temp_cycle = 8.0 * math.sin(math.pi * (hour - 8.0) / 12.0)
        temp_base = 25.0 + temp_cycle
        # Humidity tends to be inversely proportional to temperature
        humidity_base = max(20.0, min(95.0, 65.0 - (temp_cycle * 1.5)))

        if inject_noise:
            n = max(0.0, baseline["nitrogen"] + random.gauss(0, 2.5))
            p = max(0.0, baseline["phosphorus"] + random.gauss(0, 1.5))
            k = max(0.0, baseline["potassium"] + random.gauss(0, 2.0))
            ph = max(3.0, min(10.0, baseline["ph"] + random.gauss(0, 0.1)))
            moisture = max(0.0, min(100.0, baseline["moisture"] + random.gauss(0, 1.8)))
            temp = temp_base + random.gauss(0, 0.5)
            humidity = max(10.0, min(98.0, humidity_base + random.gauss(0, 1.2)))
        else:
            n = baseline["nitrogen"]
            p = baseline["phosphorus"]
            k = baseline["potassium"]
            ph = baseline["ph"]
            moisture = baseline["moisture"]
            temp = temp_base
            humidity = humidity_base

        # Optional simulated hardware anomalies (e.g. sensor wire disconnect, ADC glitch)
        if inject_anomaly:
            anomaly_type = random.choice(["dht22_disconnect", "ph_drop", "null_moisture"])
            if anomaly_type == "dht22_disconnect":
                temp = -999.0
            elif anomaly_type == "ph_drop":
                ph = 0.5  # Extreme uncalibrated reading
            elif anomaly_type == "null_moisture":
                moisture = None

        return RawSoilReading(
            device_id=self.device_id,
            farmer_id=self.farmer_id,
            timestamp=ts,
            nitrogen=round(n, 2) if n is not None else None,
            phosphorus=round(p, 2) if p is not None else None,
            potassium=round(k, 2) if k is not None else None,
            temperature=round(temp, 2) if temp is not None else None,
            humidity=round(humidity, 2) if humidity is not None else None,
            ph=round(ph, 2) if ph is not None else None,
            moisture=round(moisture, 2) if moisture is not None else None,
        )

    def generate_time_series(
        self,
        count: int = 24,
        interval_minutes: int = 60,
        start_time: Optional[datetime] = None,
        anomaly_rate: float = 0.05,
    ) -> List[RawSoilReading]:
        """
        Generates a sequence of timestamped readings spanning over hours/days.
        """
        start = start_time or (datetime.now(timezone.utc) - timedelta(minutes=count * interval_minutes))
        readings: List[RawSoilReading] = []

        for i in range(count):
            curr_time = start + timedelta(minutes=i * interval_minutes)
            is_anomaly = (random.random() < anomaly_rate)
            reading = self.generate_reading(
                timestamp=curr_time,
                inject_noise=True,
                inject_anomaly=is_anomaly
            )
            readings.append(reading)

        return readings
