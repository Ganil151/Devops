"""
Browser Automation Demo: Headless Interaction Pattern
----------------------------------------------------
This script demonstrates the Selenium logic pattern for DevOps.
Note: In headless environments, we often use 'mock' drivers or 
specific CI/CD configurations. This script showcases the OBJECT PATTERN.
"""

from typing import Optional

class MockWebDriver:
    """Simulates a Selenium WebDriver for headless logic demonstration."""
    def __init__(self, options: Optional[list] = None):
        self.options = options or []
        self.current_url = ""
        self.is_closed = False
        print(f"[Driver] Initialized with options: {self.options}")

    def get(self, url: str):
        print(f"[Browser] Navigating to: {url}")
        self.current_url = url

    def find_element(self, by: str, value: str):
        print(f"[DOM] Locating element by {by}: '{value}'")
        return MockElement(value)

    def quit(self):
        print("[Driver] Closing all browser instances and cleaning up.")
        self.is_closed = True

class MockElement:
    def __init__(self, name: str):
        self.name = name

    def send_keys(self, keys: str):
        print(f"[Input] Typing '{'********' if 'pass' in self.name.lower() else keys}' into {self.name}")

    def click(self):
        print(f"[Action] Clicking element: {self.name}")

# --- Production Pattern ---
def run_secure_login():
    print("🚀 Starting Automated Login Flow (Headless)...")
    
    # 1. Setup Options
    chrome_options = ["--headless", "--disable-gpu", "--no-sandbox"]
    
    # 2. Initialize Driver
    driver = MockWebDriver(options=chrome_options)
    
    try:
        # 3. Navigation
        driver.get("https://internal.portal.company/login")
        
        # 4. Interaction (ID-based is fastest/best)
        user_field = driver.find_element("id", "username")
        pass_field = driver.find_element("id", "password")
        login_btn = driver.find_element("id", "submit-btn")
        
        user_field.send_keys("sys_admin_bot")
        pass_field.send_keys("ComplexPassword123!")
        login_btn.click()
        
        print("\n✅ Login Sequence Orchestrated Successfully.")
        
    finally:
        # 5. Always cleanup
        driver.quit()

if __name__ == "__main__":
    run_secure_login()
