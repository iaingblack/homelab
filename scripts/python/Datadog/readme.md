Run scripts like this.

```
python3 -m venv ./venv
source ./venv/bin/activate
python3 -m pip install -r requirements.txt

export DD_API_KEY="_key_"
export DD_APP_KEY="_key_"

python3 mute_monitor.py
```

Docs here
# https://github.com/DataDog/datadog-api-client-python/tree/master
# https://docs.datadoghq.com/api/latest/monitors/#update-a-monitor
# https://docs.datadoghq.com/api/latest/monitors/