# 🛠️ API Challenges

## Challenge 1: GitHub Repo Lister
**Objective**: Fetch a user's repositories using the GitHub API.
1.  Endpoint: `https://api.github.com/users/{username}/repos`
2.  Use `requests.get()` to fetch data for username "octocat".
3.  Check status code (200).
4.  Parse the JSON.
5.  Loop and print `name` and `stargazers_count` for each repo.

## Challenge 2: Broken Link Checker
**Objective**: Verify a list of URLs.
1.  List: `["https://google.com", "https://httpstat.us/404", "https://httpstat.us/500"]`
2.  Loop through URLs.
3.  Use `requests.head()` (HEAD request is faster, only headers).
4.  If status is 200, print "Configured".
5.  If 404, print "Broken".
6.  If 500, print "Server Error".
7.  Handle `ConnectionError` for invalid domains.

## Challenge 3: Payload Poster
**Objective**: Post JSON data to an echo server.
1.  Endpoint: `https://httpbin.org/post`
2.  Data: `{"deployment": "v1.0", "status": "active"}`
3.  Use `requests.post(url, json=data)`.
4.  Verify that the response contains your data (httpbin echoes it back).
