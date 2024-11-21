import os
import requests
import argparse
from datadog_api_client import ApiClient, Configuration
from datadog_api_client.v1.api.monitors_api import MonitorsApi
from datetime import datetime, timedelta

def mute_monitors(client_name_search: str, pause_duration_in_hours: int,):
    """
    Mutes Datadog monitors that match the client_name_search for the specified duration.
    
    Args:
        pause_duration_in_hours (int): The duration to mute monitors, in hours.
        client_name_search (str): The substring to search for in monitor names.
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
            monitor for monitor in monitors if client_name_search.lower() in monitor.name.lower()
        ]

    if matching_monitors:
        print(f"Found {len(matching_monitors)} monitors with '{client_name_search}' in the name:")
        for monitor in matching_monitors:
            print(f" - ID: {monitor.id}, Name: {monitor.name}")

            # Calculate mute end time
            mute_end_time = int((datetime.now().astimezone().timestamp()) + (pause_duration_in_hours * 3600))
            
            # API request to mute the monitor
            url = f"https://api.{dd_site}/api/v1/monitor/{monitor.id}/mute"
            headers = {
                "Accept": "application/json",
                "DD-API-KEY": dd_api_key,
                "DD-APPLICATION-KEY": dd_app_key,
            }
            query_params = {
                "end": mute_end_time,
            }

            response = requests.post(url, headers=headers, params=query_params)

            # Check the response
            if response.status_code == 200:
                print(f"Monitor {monitor.id} muted successfully:", response.json())
            else:
                print(f"Failed to mute monitor {monitor.id}. Status code: {response.status_code}, Response: {response.text}")
    else:
        print(f"No monitors found with '{client_name_search}' in the name.")

# Example usage:
# Mute monitors with 'Client' in the name for 4 hours
# python3 mute_monitor.py "Client" 4

if __name__ == "__main__":
    # Argument parser
    parser = argparse.ArgumentParser(description="Mute Datadog monitors based on name and duration.")
    parser.add_argument("client_name_search", type=str, help="Substring to search for in monitor names.")    
    parser.add_argument("pause_duration_hours", type=int, help="Duration to mute the monitors in hours.")

    args = parser.parse_args()

    # Call the function with parsed arguments
    mute_monitors(args.client_name_search, args.pause_duration_hours)
