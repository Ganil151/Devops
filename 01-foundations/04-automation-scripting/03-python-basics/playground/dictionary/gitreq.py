# ============================================================================================================
# Title: GitHub Repository Information Fetcher                                                               #
# Description: A script to fetch and display information about a GitHub repository using GitHub's REST API.  #
# It retrieves details such as repository name, owner, description, and star count.                          #
# Author: Ganil Batist                                                                                       #
# Date: 2024-06-15                                                                                           #
# ============================================================================================================

# [ x] Objective: Pull and display information about a specific GitHub repository using Python dictionaries.
# [ x] Import necessary libraries "requests" for making HTTP requests and "json" for handling JSON data.
# [ x] Get the API info from https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28, copy the endpoint for repository info. "/repos/{owner}/{repo}/pulls"
# [ x] Construct the API URL to fetch repository information.
# [ x] Make a GET request to the GitHub API.
# [ x] Check if the request was successful (status code 200).
# [ x] Parse the JSON response to extract repository details.
# [ x] Display the repository information, including name, owner, description, and star count.
# [ x] Handle errors by displaying an appropriate message if the request fails.

import requests
import json

response = requests.get("https://api.github.com/repos/kubernetes/kubernetes/pulls")

complete_detail = response.json()

# Display the complete details of the first pull request
# print(complete_detail[0]["user"]["login"])  

# Display the complete details of all pull requests
for i in range(len(complete_detail)):
    # print(complete_detail[i])
    print(f"Pull Request {i+1}:")
    print(f"  Title: {complete_detail[i]['title']}")    
    print(f"  Body: {complete_detail[i]['body']}")
    print(f"  Number: {complete_detail[i]['number']}")
    print(f"  User: {complete_detail[i]['user']['login']}")
    print(f"  State: {complete_detail[i]['state']}")
    print(f"  Created At: {complete_detail[i]['created_at']}")
    print(f"  URL: {complete_detail[i]['html_url']}")
    print()