import pandas as pd
from datetime import datetime

# Load CSV file into a DataFrame
# Replace 'file.csv' with the path to your actual CSV file
df = pd.read_csv('btcusd_1-min_data.csv')

# Convert the 'Timestamp' column to a readable datetime format
df['Date'] = pd.to_datetime(df['Timestamp'], unit='s')

# Example: Query data for a specific date
# Replace 'YYYY-MM-DD' with the desired date
query_date = '2012-12-31'  # Example date
result = df[df['Date'].dt.strftime('%Y-%m-%d') == query_date]

print(result)
