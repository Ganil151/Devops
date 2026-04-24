"""
Challenge: Weather Alert CLI
Scenario: You are an SRE for an outdoor event company. You need a script 
that checks the weather and alerts the crew on Slack if conditions 
become dangerous.

TODO: Implement `check_weather_and_alert(city, webhook_url)`.
1. Use a weather API (like OpenWeatherMap) OR mock the response for testing.
2. The response should contain `wind_speed` and `conditions`.
3. If `wind_speed` > 50 OR `conditions` == "Storm", send a Slack alert.
4. The Slack message should be formatted as JSON with a "text" key.
"""
import requests
import os

def check_weather_and_alert(city, webhook_url):
    """
    Checks weather and sends Slack alerts for dangerous conditions.
    """
    # Mock Response for development
    mock_response = {
        "name": city,
        "wind_speed": 65,
        "conditions": "Rainy"
    }
    # --- START YOUR CODE HERE ---
    pass

if __name__ == "__main__":
    # Use a dummy webhook URL unless you have a real one
    WEBHOOK = os.getenv("SLACK_WEBHOOK", "https://hooks.slack.com/services/...")
    check_weather_and_alert("Chicago", WEBHOOK)
