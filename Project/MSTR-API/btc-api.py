from fastapi import FastAPI, Query, HTTPException
from typing import Optional
import pandas as pd
from datetime import datetime

# Initialize FastAPI app
app = FastAPI()

# Load CSV into a DataFrame when the app starts
df = pd.read_csv('btcusd_1-min_data.csv', sep=",", header=0) #, index_col='Timestamp')  # Replace 'file.csv' with your actual file path
print(df.columns.tolist()) 
df['Date'] = pd.to_datetime(df['Timestamp'], unit='s')  # Convert Timestamp to datetime
df.index = df['Date']  # Set the Date column as the DataFrame index

@app.get("/")
def read_root():
    return {"message": "Welcome to the CSV Query API"}

@app.get("/query/")
def query_data(date: str = Query(..., description="Date in YYYY-MM-DD format")):
    """
    Query data by a specific date in the format YYYY-MM-DD.
    """
    try:
        # Validate the input date format
        query_date = datetime.strptime(date, '%Y-%m-%d')
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")

    # Filter data by the provided date
    filtered_data = df[df['Date'].dt.strftime('%Y-%m-%d') == query_date.strftime('%Y-%m-%d')]

    # Check if data exists for the given date
    if filtered_data.empty:
        raise HTTPException(status_code=404, detail="No data found for the given date.")

    # Convert the filtered data to a JSON-friendly format
    result = filtered_data.to_dict(orient='records')
    return {"data": result}
