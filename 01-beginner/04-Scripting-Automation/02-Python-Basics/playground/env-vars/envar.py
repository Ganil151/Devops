import os 

print(os.getenv("password"))
print(os.getenv("api_token"))

# In the terminal, you can set the environment variables like this:
# export password="your_password"
# export api_token="your_api_token"

# To remove an environment variable, you can use:
# unset password  
# unset api_token
