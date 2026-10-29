
import requests

URL = "https://api.open-meteo.com/v1/forecast"


def get_weather(latitude=26.9124, longitude=75.7873):
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": (
            "temperature_2m,relative_humidity_2m,"
            "rain,precipitation"
        ),
        "timezone": "Asia/Kolkata",
    }

    response = requests.get(URL, params=params, timeout=15)
    response.raise_for_status()
    current = response.json()["current"]

    return {
        "temperature": current["temperature_2m"],
        "humidity": current["relative_humidity_2m"],
        "rainfall": current["precipitation"],
        "precipitation_mm": current["precipitation"],
        "time": current["time"],
    }


if __name__ == "__main__":
    print(get_weather())
