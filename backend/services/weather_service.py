import requests
import os

API_KEY = os.getenv("WEATHER_API_KEY", "4ae8bf4d587a4ddb88b144032260603")

def get_seasonal_weather(city):
    """
    Fetches 7-day forecast and computes averages for seasonal prediction.
    """
    url = f"http://api.weatherapi.com/v1/forecast.json?key={API_KEY}&q={city}&days=7"
    
    try:
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
            "condition": data['current']['condition']['text']
        }, None
    except Exception as e:
        return None, f"Forecast API Error: {str(e)}"

def get_weather_by_coords(lat, lon):
    url = f"http://api.weatherapi.com/v1/current.json?key={API_KEY}&q={lat},{lon}"
    try:
        response = requests.get(url, timeout=10)
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
        return None, str(e)

# Keep original function for backward compatibility
def get_weather_data(city):
    url = f"http://api.weatherapi.com/v1/current.json?key={API_KEY}&q={city}"
    try:
        response = requests.get(url, timeout=10)
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
        return None, str(e)
