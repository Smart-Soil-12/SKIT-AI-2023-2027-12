
"""FastAPI endpoints for SmartSoil AI."""

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, ConfigDict, Field
from requests import RequestException

from src.firebase_service import get_latest_soil_reading
from src.weather_service import get_weather
from src.ml.predict_crop import FEATURE_RANGES, predict_crop

app = FastAPI(
    title="SmartSoil AI API",
    version="1.0.0",
    description="Soil data, weather, and crop recommendations.",
)


class CropPredictionRequest(BaseModel):
    """Six features required by the crop prediction model."""

    model_config = ConfigDict(extra="forbid", allow_inf_nan=False)

    N: float = Field(ge=FEATURE_RANGES["N"][0], le=FEATURE_RANGES["N"][1])
    P: float = Field(ge=FEATURE_RANGES["P"][0], le=FEATURE_RANGES["P"][1])
    K: float = Field(ge=FEATURE_RANGES["K"][0], le=FEATURE_RANGES["K"][1])

    temperature: float = Field(
        ge=FEATURE_RANGES["temperature"][0],
        le=FEATURE_RANGES["temperature"][1],
    )

    humidity: float = Field(
        ge=FEATURE_RANGES["humidity"][0],
        le=FEATURE_RANGES["humidity"][1],
    )

    ph: float = Field(
        ge=FEATURE_RANGES["ph"][0],
        le=FEATURE_RANGES["ph"][1],
    )


class CropPrediction(BaseModel):
    crop: str
    confidence: float = Field(ge=0, le=100)


class CropPredictionResponse(BaseModel):
    recommendations: list[CropPrediction] = Field(
        min_length=1, max_length=3
    )


@app.get("/health")
def health():
    return {"status": "ok", "service": "SmartSoil AI API"}


@app.get("/api/weather/current")
def current_weather(
    latitude: float = Query(26.9124, ge=-90, le=90),
    longitude: float = Query(75.7873, ge=-180, le=180),
):
    """Return current weather and forecast data, including rainfall."""
    try:
        return get_weather(latitude, longitude)

    except RequestException as exc:
        raise HTTPException(
            status_code=502,
            detail="Weather service unavailable.",
        ) from exc

    except (KeyError, ValueError) as exc:
        raise HTTPException(
            status_code=502,
            detail="Invalid response from weather service.",
        ) from exc


@app.post("/api/crops/predict", response_model=CropPredictionResponse)
def crop_prediction(payload: CropPredictionRequest):
    """Return the model's three highest-ranked crops."""
    try:
        recommendations = predict_crop(payload.model_dump())

    except FileNotFoundError as exc:
        raise HTTPException(
            status_code=503,
            detail="Crop prediction model is unavailable.",
        ) from exc

    except ValueError as exc:
        raise HTTPException(
            status_code=422,
            detail="Crop prediction inputs are invalid.",
        ) from exc

    return {"recommendations": recommendations}


@app.get("/api/crops/predict/latest")
def predict_latest_crops(
    latitude: float = Query(26.9124, ge=-90, le=90),
    longitude: float = Query(75.7873, ge=-180, le=180),
):
    """Predict crops using the latest Firebase soil reading and weather."""
    try:
        soil = get_latest_soil_reading()

        if not soil:
            raise HTTPException(
                status_code=404,
                detail="No soil readings found.",
            )

        weather = get_weather(latitude, longitude)

        # Six features only. Rainfall remains available through
        # the weather endpoint but is not used by the crop model.
        inputs = {
            "N": soil["N"],
            "P": soil["P"],
            "K": soil["K"],
            "temperature": weather["temperature"],
            "humidity": weather["humidity"],
            "ph": soil["pH"],
        }

        recommendations = predict_crop(inputs)

        return {"recommendations": recommendations}

    except HTTPException:
        raise

    except RequestException as exc:
        raise HTTPException(
            status_code=502,
            detail="Weather service unavailable.",
        ) from exc

    except (KeyError, TypeError, ValueError) as exc:
        raise HTTPException(
            status_code=422,
            detail="Required soil or weather data is missing or invalid.",
        ) from exc

    except FileNotFoundError as exc:
        raise HTTPException(
            status_code=503,
            detail="Crop prediction model is unavailable.",
        ) from exc
