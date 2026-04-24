"""
Solution: Weather Alert CLI
"""
import requests

def check_weather_and_alert(city, webhook_url):
    # Simulated API response (In production, you'd use requests.get() to an API)
    data = {
        "name": city,
        "wind_speed": 65,
        "conditions": "Storm"
    }
    
    threshold_wind = 50
    is_danger = data["wind_speed"] > threshold_wind or data["conditions"] == "Storm"
    
    if is_danger:
        payload = {
            "text": f"🚨 *Weather Alert for {city}*\n"
                    f"Warning: {data['conditions']} with {data['wind_speed']}km/h winds.\n"
                    f"Secure all outdoor equipment immediately!"
        }
        try:
            response = requests.post(webhook_url, json=payload, timeout=5)
            return response.status_code == 200
        except Exception as e:
            print(f"Failed to send Slack alert: {e}")
            return False
    
    return True

if __name__ == "__main__":
    # Test logic
    pass
