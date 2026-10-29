import requests

URL = "https://api.open-meteo.com/v1/forecast"


def get_weather(latitude=26.9124, longitude=75.7873):
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "daily": "temperature_2m_mean,precipitation_sum",
        "current": "relative_humidity_2m",
        "forecast_days": 16,
        "timezone": "Asia/Kolkata",
    }

    response = requests.get(URL, params=params, timeout=15)
    response.raise_for_status()
    data = response.json()

    return {
        "temperature": data["daily"]["temperature_2m_mean"][0],
        "humidity": data["current"]["relative_humidity_2m"],
        "rainfall": sum(
          value or 0
          for value in data["daily"]["precipitation_sum"]
        ),
        "rainfall_period": "16-day forecast (mm)",
        "time": data["daily"]["time"][0],
    }


if __name__ == "__main__":
    print(get_weather())