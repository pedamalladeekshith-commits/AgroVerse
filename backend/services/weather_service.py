import requests
import os

API_KEY = os.getenv("WEATHER_API_KEY", "4ae8bf4d587a4ddb88b144032260603")

FALLBACK_WEATHER = {
    "bangalore": {"avg_temp": 24.0, "avg_humidity": 68.0, "total_rainfall": 150.0, "region": "Karnataka"},
    "bengaluru": {"avg_temp": 24.0, "avg_humidity": 68.0, "total_rainfall": 150.0, "region": "Karnataka"},
    "mysore": {"avg_temp": 25.0, "avg_humidity": 70.0, "total_rainfall": 120.0, "region": "Karnataka"},
    "hyderabad": {"avg_temp": 29.0, "avg_humidity": 58.0, "total_rainfall": 80.0, "region": "Telangana"},
    "mumbai": {"avg_temp": 30.0, "avg_humidity": 75.0, "total_rainfall": 250.0, "region": "Maharashtra"},
    "pune": {"avg_temp": 27.0, "avg_humidity": 62.0, "total_rainfall": 110.0, "region": "Maharashtra"},
    "delhi": {"avg_temp": 31.0, "avg_humidity": 45.0, "total_rainfall": 60.0, "region": "Delhi"},
    "chennai": {"avg_temp": 31.0, "avg_humidity": 72.0, "total_rainfall": 180.0, "region": "Tamil Nadu"},
}


def _fallback_seasonal_weather(city, reason):
    profile = FALLBACK_WEATHER.get((city or "").strip().lower())
    if profile is None:
        profile = {"avg_temp": 27.0, "avg_humidity": 65.0, "total_rainfall": 45.0, "region": "India"}

    return {
        "avg_temp": profile["avg_temp"],
        "avg_humidity": profile["avg_humidity"],
        "total_rainfall": profile["total_rainfall"],
        "city": city or "Unknown",
        "region": profile["region"],
        "condition": "Estimated seasonal average",
        "is_fallback": True,
        "fallback_reason": str(reason),
    }, None


def _fallback_current_weather(city, reason):
    profile = FALLBACK_WEATHER.get((city or "").strip().lower())
    if profile is None:
        profile = {"avg_temp": 27.0, "avg_humidity": 65.0, "total_rainfall": 0.0, "region": "India"}

    return {
        "temperature": profile["avg_temp"],
        "humidity": profile["avg_humidity"],
        "rainfall": 0.0,
        "city": city or "Unknown",
        "region": profile["region"],
        "condition": "Estimated weather",
        "is_fallback": True,
        "fallback_reason": str(reason),
    }, None

def get_seasonal_weather(city):
    """
    Fetches 7-day forecast and computes averages for seasonal prediction.
    Adds fallback for unrecognized locations.
    """
    url = f"http://api.weatherapi.com/v1/forecast.json?key={API_KEY}&q={city}&days=7"
    
    try:
        response = requests.get(url, timeout=10)
        
        # If city not found (400), try fallback to region or default
        if response.status_code == 400:
            # Try a broader search (e.g., state capital or regional center)
            # For simplicity in this fix, we'll try a known fallback like 'Bangalore'
            # if the original city was a village in Karnataka.
            fallback_city = "Bangalore"
            url = f"http://api.weatherapi.com/v1/forecast.json?key={API_KEY}&q={fallback_city}&days=7"
            response = requests.get(url, timeout=10)
            
        response.raise_for_status()
        data = response.json()
        
        forecast_days = data['forecast']['forecastday']
        
        avg_temp = sum(day['day']['avgtemp_c'] for day in forecast_days) / len(forecast_days)
        avg_humidity = sum(day['day']['avghumidity'] for day in forecast_days) / len(forecast_days)
        total_rainfall = sum(day['day']['totalprecip_mm'] for day in forecast_days)
        
        return {
            "avg_temp": round(avg_temp, 2),
            "avg_humidity": round(avg_humidity, 2),
            "total_rainfall": round(total_rainfall, 2),
            "city": data['location']['name'],
            "region": data['location']['region'],
            "condition": data['current']['condition']['text'],
            "is_fallback": response.url.find(city) == -1 # Mark if fallback was used
        }, None
    except Exception as e:
        return _fallback_seasonal_weather(city, e)

def get_weather_by_coords(lat, lon):
    url = f"http://api.weatherapi.com/v1/current.json?key={API_KEY}&q={lat},{lon}"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()
        return {
            "temperature": data["current"]["temp_c"],
            "humidity": data["current"]["humidity"],
            "rainfall": data["current"]["precip_mm"],
            "city": data["location"]["name"],
            "region": data["location"]["region"],
            "condition": data["current"]["condition"]["text"]
        }, None
    except Exception as e:
        return _fallback_current_weather("Current location", e)

# Keep original function for backward compatibility
def get_weather_data(city):
    url = f"http://api.weatherapi.com/v1/current.json?key={API_KEY}&q={city}"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json()
        return {
            "temperature": data["current"]["temp_c"],
            "humidity": data["current"]["humidity"],
            "rainfall": data["current"]["precip_mm"],
            "city": data["location"]["name"],
            "region": data["location"]["region"],
            "condition": data["current"]["condition"]["text"]
        }, None
    except Exception as e:
        return _fallback_current_weather(city, e)
