# Mutes a monitor for 4 hours if the monitor name contains the search string "Client".

import os, requests
from datadog_api_client import ApiClient, Configuration
from datadog_api_client.v1.api.monitors_api import MonitorsApi
from datetime import datetime, timedelta

# Read Datadog keys from environment variables
dd_api_key = os.getenv("DD_API_KEY")
dd_app_key = os.getenv("DD_APP_KEY")
dd_site = "datadoghq.eu"

if not dd_api_key or not dd_app_key:
    raise ValueError("DATADOG_API_KEY and DATADOG_APP_KEY environment variables must be set.")

# Configure API key authorization
configuration = Configuration()
configuration.api_key["apiKeyAuth"] = dd_api_key
configuration.api_key["appKeyAuth"] = dd_app_key
configuration.server_variables["site"] = dd_site

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
        # Mute the monitor for 4 hours
        mute_end_time = int((datetime.now().astimezone().timestamp()) + (4 * 3600))
        # https://docs.datadoghq.com/api/latest/monitors/?code-lang=curl#mute-a-monitor
        url = f"https://api.{dd_site}/api/v1/monitor/{monitor.id}/mute"
        headers = {
            "Accept": "application/json",
            "DD-API-KEY": dd_api_key,
            "DD-APPLICATION-KEY": dd_app_key,
        }
        query_params = {
            # "scope": "host:app1",  # Example: mute for a specific host
            "end": mute_end_time,     # Example: POSIX timestamp for the mute end time
        }
        response = requests.post(url, headers=headers, params=query_params)

        # Check the response
        if response.status_code == 200:
            print("Monitor muted successfully:", response.json())
        else:
            print(f"Failed to mute monitor. Status code: {response.status_code}, Response: {response.text}")
else:
    print(f"No monitors found with '{search_string}' in the name.")

