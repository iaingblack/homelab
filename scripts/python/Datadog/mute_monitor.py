import os
import requests
from datadog_api_client import ApiClient, Configuration
from datadog_api_client.v1.api.monitors_api import MonitorsApi
from datetime import datetime
import argparse

def mute_monitors(pause_duration_hours: int, client_name: str, scope: str):
    """
    Mutes Datadog monitors that match the client_name for the specified duration.
    """
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

    # Use the API to list all monitors and filter by name
    with ApiClient(configuration) as api_client:
        api_instance = MonitorsApi(api_client)
        monitors = api_instance.list_monitors()  # Fetch all monitors

        # Filter monitors that contain the client name in their name
        matching_monitors = [
            monitor for monitor in monitors 
            if client_name.lower() in monitor.name.lower() and scope in (monitor.tags or [])
        ]


    if matching_monitors:
        print(f"Found {len(matching_monitors)} monitors with '{client_name}' in the name:")
        for monitor in matching_monitors:
            print(f" - ID: {monitor.id}, Name: {monitor.name}")

            # Calculate mute end time
            mute_end_time = int((datetime.now().astimezone().timestamp()) + (pause_duration_hours * 3600))
            
            # API request to mute the monitor
            url = f"https://api.{dd_site}/api/v1/monitor/{monitor.id}/mute"
            headers = {
                "Accept": "application/json",
                "DD-API-KEY": dd_api_key,
                "DD-APPLICATION-KEY": dd_app_key,
            }
            query_params = {
                "end": mute_end_time,
                "scope": scope,
            }
            response = requests.post(url, headers=headers, params=query_params)

            # Check the response
            if response.status_code == 200:
                print(f"Monitor {monitor.id} muted successfully:") #, response.json())
                # response.json()
            else:
                print(f"Failed to mute monitor {monitor.id}. Status code: {response.status_code}, Response: {response.text}")
    else:
        print(f"No monitors found with '{client_name}' or '{scope}' in the name.")

def unmute_monitors(client_name: str, scope: str):
    """
    Unmutes Datadog monitors that match the client_name.
    """
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

    # Use the API to list all monitors and filter by name
    with ApiClient(configuration) as api_client:
        api_instance = MonitorsApi(api_client)
        monitors = api_instance.list_monitors()  # Fetch all monitors

        # Filter monitors that contain the client name in their name
        matching_monitors = [
            monitor for monitor in monitors if client_name.lower() in monitor.name.lower()
        ]

    if matching_monitors:
        print(f"Found {len(matching_monitors)} monitors with '{client_name}' in the name:")
        for monitor in matching_monitors:
            print(f" - ID: {monitor.id}, Name: {monitor.name}")

            # API request to unmute the monitor
            url = f"https://api.{dd_site}/api/v1/monitor/{monitor.id}/unmute"
            headers = {
                "Accept": "application/json",
                "DD-API-KEY": dd_api_key,
                "DD-APPLICATION-KEY": dd_app_key,
            }
            query_params = {
                "scope": scope,
            }

            response = requests.post(url, headers=headers, params=query_params)

            # Check the response
            if response.status_code == 200:
                print(f"Monitor {monitor.id} unmuted successfully:", response.json())
            else:
                print(f"Failed to unmute monitor {monitor.id}. Status code: {response.status_code}, Response: {response.text}")
    else:
        print(f"No monitors found with '{client_name}' in the name.")

if __name__ == "__main__":
    # Argument parser
    parser = argparse.ArgumentParser(description="Mute or unmute Datadog monitors based on name and duration.")
    parser.add_argument("action", type=str, choices=["mute", "unmute"], help="Action to perform: mute or unmute.")
    parser.add_argument("client_name", type=str, help="Substring to search for in monitor names.")
    parser.add_argument("--duration", type=int, default=4, help="Duration to mute monitors in hours (only for 'mute').")
    parser.add_argument("--scope", type=str, default="application:sghosted", help="Scope to apply the mute or unmute.")


    args = parser.parse_args()

    # Call the appropriate function based on the action
    if args.action == "mute":
        mute_monitors(args.duration, args.client_name, args.scope)
    elif args.action == "unmute":
        unmute_monitors(args.client_name, args.scope)

# To run the script:
# export DATADOG_API_KEY=your_api_key
# export DATADOG_APP_KEY=your_app_key
# python mute_monitor.py mute "Client" --duration 4 --scope "application:sghosted"
# python mute_monitor.py unmute "Client" --scope "application:sghosted"