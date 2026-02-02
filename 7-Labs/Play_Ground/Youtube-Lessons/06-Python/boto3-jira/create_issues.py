# This code sample uses the 'requests' library:
# http://docs.python-requests.org
import requests
from requests.auth import HTTPBasicAuth
import json
import os


url = "https://ganilbatistyan.atlassian.net/rest/api/3/changelog/bulkfetch"

auth = HTTPBasicAuth("ganilbatistyan@gmail.com", os.getenv("API_TOKEN") ) 

headers = {
  "Accept": "application/json",
  "Content-Type": "application/json"
}

payload = json.dumps( {
  "fieldIds": [
    "<string>"
  ],
  "issueIdsOrKeys": [
    "<string>"
  ],
  "maxResults": 46,
  "nextPageToken": "<string>"
} )

response = requests.request(
   "POST",
   url,
   data=payload,
   headers=headers,
   auth=auth
)

print(json.dumps(json.loads(response.text), sort_keys=True, indent=4, separators=(",", ": ")))