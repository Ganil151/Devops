# 🎯 Web Automation - Challenges

> **"A browser is a heavy tool. Use it only when the API is a ghost. These challenges test your ability to drive the 'Digital Ghost' through complex UIs."**

---

## 🏆 Challenge 1: The Headless Searcher
**Difficulty**: ⭐ Beginner  
**Estimated Time**: 20 minutes

### Objective
Create a script that opens a search engine, types a query, and captures the title of the results page.

### Requirements
- Run Chrome or Firefox in **Headless** mode.
- Navigate to `https://duckduckgo.com`.
- Find the search box element.
- Type "DevOps Automation with Python" and hit Enter.
- Print the title of the page after the results load.

### Hints
- Use `By.NAME` to find the search input (usually named `q`).
- Use `driver.title`.

---

## 🏆 Challenge 2: The Login Bot
**Difficulty**: ⭐⭐ Intermediate  
**Estimated Time**: 35 minutes

### Objective
Automate a login process on a test website and verify success.

### Requirements
- Target: `https://practicetestautomation.com/practice-test-login/`.
- Enter username: `student`.
- Enter password: `Password123`.
- Click Submit.
- Use an **Explicit Wait** to wait for the "Logged In Successfully" message to appear.
- Print "Login Success!" if found, otherwise "Failed."

### Hints
- Use `WebDriverWait(driver, 10).until(...)`.
- Look for `expected_conditions.visibility_of_element_located`.

---

## 🏆 Challenge 3: The Data Scraper (Shadow DOM)
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 50 minutes

### Objective
Extract data from a table that is loaded dynamically via JavaScript.

### Requirements
- Navigate to a site with a dynamic table (e.g., a stock market dashboard or a mock table).
- Wait for the table rows to load.
- Iterate through the first 5 rows.
- Extract the text from two columns (e.g., "Company Name" and "Price").
- Save the results to a CSV file.

### Hints
- Use `driver.find_elements(By.CSS_SELECTOR, "tr")` only after an explicit wait.

---

## 🎓 Bonus Challenge: The Crash Debugger
**Difficulty**: ⭐⭐⭐ Advanced  
**Estimated Time**: 40 minutes

### Objective
Build a script that takes a screenshot automatically if an element is NOT found.

### Requirements
- Try to find a non-existent element `id="hidden_button"`.
- Use a `try/except` block to catch the `NoSuchElementException`.
- In the `except` block, use `driver.save_screenshot("error_state.png")`.
- Log the error with the timestamp.

---

## ✅ Completion Checklist
- [ ] Challenge 1: Headless Searcher
- [ ] Challenge 2: Login Bot
- [ ] Challenge 3: Data Scraper
- [ ] Bonus: Crash Debugger
