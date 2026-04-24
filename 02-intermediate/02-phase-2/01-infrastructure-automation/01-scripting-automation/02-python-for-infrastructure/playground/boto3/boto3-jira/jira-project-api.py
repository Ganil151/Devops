# This code sample uses the 'requests' library:
# http://docs.python-requests.org
import requests
from requests.auth import HTTPBasicAuth
import json
import os

url = "https://ganilbatistyan.atlassian.net/rest/api/3/project"

auth = HTTPBasicAuth("ganilbatistyan@gmail.com", os.getenv("API_TOKEN"))

headers = {"Accept": "application/json"}

response = requests.request("GET", url, headers=headers, auth=auth)

output = json.loads(response.text)
name = output[0]["name"]
# print(f"Project Name: {name}")


print(name)
