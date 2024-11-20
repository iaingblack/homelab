import os
from datadog_api_client import ApiClient, Configuration
from datadog_api_client.v1.api.monitors_api import MonitorsApi

# python3 -m venv ./venv
# source ./venv/bin/activate
# python3 -m pip install datadog-api-client

# Read Datadog keys from environment variables
dd_api_key = os.getenv("DD_API_KEY")
dd_app_key = os.getenv("DD_APP_KEY")

if not dd_api_key or not dd_app_key:
    raise ValueError("DATADOG_API_KEY and DATADOG_APP_KEY environment variables must be set.")

# Configure API key authorization
configuration = Configuration()
configuration.api_key["apiKeyAuth"] = dd_api_key
configuration.api_key["appKeyAuth"] = dd_app_key
configuration.server_variables["site"] = "datadoghq.eu"

# Define the search string
search_string = "Client"

# Use the API to list all monitors and filter by name
with ApiClient(configuration) as api_client:
    api_instance = MonitorsApi(api_client)
    # Fetch all monitors (or adjust the query parameters as needed)
    monitors = api_instance.list_monitors()
    
    # Filter monitors that contain the search string in their name
    matching_monitors = [
        monitor for monitor in monitors if search_string.lower() in monitor.name.lower()
    ]

# Print matching monitors
if matching_monitors:
    print(f"Found {len(matching_monitors)} monitors with '{search_string}' in the name:")
    for monitor in matching_monitors:
        print(f" - ID: {monitor.id}, Name: {monitor.name}")
else:
    print(f"No monitors found with '{search_string}' in the name.")
