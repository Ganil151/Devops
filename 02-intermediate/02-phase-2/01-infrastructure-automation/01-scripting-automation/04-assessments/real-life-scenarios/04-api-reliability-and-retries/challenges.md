# 🛠️ API Reliability Challenges

## Challenge 1: The Fast Fail
**Objective**: Use strict timeouts.
1.  Call `https://httpbin.org/delay/10` (Wait 10 seconds).
2.  Set a `timeout=2`.
3.  Catch the `requests.exceptions.Timeout` error and print "Service too slow, moving on".

## Challenge 2: Custom Backoff
**Objective**: Manual retry logic.
1.  Don't use `HTTPAdapter`.
2.  Write a `for` loop that tries a request.
3.  If it fails, use `time.sleep(i * 2)` and retry.
4.  If it fails 3 times, raise a custom error.

## Challenge 3: Status Validator
**Objective**: Defensive response handling.
1.  Check if the response header `Content-Type` is exactly `application/json`.
2.  If not (e.g., you got a maintenance HTML page instead), do NOT call `response.json()`.
3.  Fail gracefully with "Invalid API response format".
