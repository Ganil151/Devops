# 🛠️ Testing Challenges

## Challenge 1: The API Client Test
**Objective**: Mock an API response so you don't hit the real internet.
1.  Function to test: `get_user(username)` from `api_code.py` (create a dummy one).
2.  Use `requests_mock` (or `unittest.mock`).
3.  Simulate a 200 OK with `{"login": "testuser"}`.
4.  Assert that your function returns the correct username.
5.  Simulate a 404 and assert your function raises an error.

## Challenge 2: Boto3 Mock with Moto
**Objective**: Test an S3 uploader without needing AWS credentials.
1.  Install `moto`.
2.  Use the `@mock_s3` decorator.
3.  Inside the test, create a bucket `my-test-bucket`.
4.  Call your `upload_file(file, bucket)` function.
5.  Assert the object exists in the fake S3.
