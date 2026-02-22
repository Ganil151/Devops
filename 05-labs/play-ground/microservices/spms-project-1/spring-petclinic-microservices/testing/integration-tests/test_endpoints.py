import requests
import sys

def check_service(url, service_name):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            print(f"[PASS] {service_name} is reachable.")
            return True
        else:
            print(f"[FAIL] {service_name} returned status code {response.status_code}.")
            return False
    except requests.exceptions.RequestException as e:
        print(f"[FAIL] {service_name} is unreachable. Error: {e}")
        return False

if __name__ == "__main__":
    services = [
        {"name": "API Gateway", "url": "http://localhost:8080"},
        {"name": "Customers Service", "url": "http://localhost:8081/owners"},
        {"name": "Vets Service", "url": "http://localhost:8082/vets"},
        {"name": "Visits Service", "url": "http://localhost:8083/visits"},
    ]

    all_passed = True
    for service in services:
        if not check_service(service["url"], service["name"]):
            all_passed = False

    if all_passed:
        print("\nAll integration tests passed!")
        sys.exit(0)
    else:
        print("\nSome integration tests failed.")
        sys.exit(1)
