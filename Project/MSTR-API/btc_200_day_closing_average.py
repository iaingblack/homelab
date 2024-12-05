from fastapi import FastAPI, Query, HTTPException
from datetime import datetime
import pandas as pd

app = FastAPI()

# Load and preprocess the data
csv_file = "btcusd_1-day_data.csv"
df = pd.read_csv(csv_file)

# Convert the Date column to datetime.date
df['Date'] = pd.to_datetime(df['Date']).dt.date

# Calculate the 200-day moving average
df['200d_MA'] = df['Close'].rolling(window=200, min_periods=1).mean()

@app.get("/moving-average/")
def get_moving_average(start_date: str, end_date: str):
    """
    Get the 200-day moving average between two dates.
    """
    try:
        # Convert input dates to datetime.date
        start_date = datetime.strptime(start_date, "%Y-%m-%d").date()
        end_date = datetime.strptime(end_date, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")
    
    # Validate date range
    if start_date > end_date:
        raise HTTPException(status_code=400, detail="Start date must be before end date.")
    
    # Filter data within the date range
    filtered_data = df[(df['Date'] >= start_date) & (df['Date'] <= end_date)]
    
    if filtered_data.empty:
        raise HTTPException(status_code=404, detail="No data available for the given date range.")
    
    # Return the filtered data
    return filtered_data[['Date', '200d_MA']].to_dict(orient="records")
