from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import FileResponse
from datetime import datetime
import pandas as pd
import matplotlib.pyplot as plt
import os

app = FastAPI()

# Sample dataset
data = {
    "Date": ["2012-01-01", "2012-01-02", "2012-01-03", "2012-01-04", "2012-01-05"],
    "Close": [4.58, 4.84, 5.00, 5.20, 5.10]
}
df = pd.DataFrame(data)
df['Date'] = pd.to_datetime(df['Date'])
df['200d_MA'] = df['Close'].rolling(window=200, min_periods=1).mean()

@app.get("/plot/")
def plot_moving_average(start_date: str, end_date: str):
    """
    Generate and return a graph of the 200-day moving average between two dates.
    """
    try:
        # Convert input dates to datetime
        start_date = datetime.strptime(start_date, "%Y-%m-%d")
        end_date = datetime.strptime(end_date, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD.")
    
    # Filter data
    filtered_data = df[(df['Date'] >= start_date) & (df['Date'] <= end_date)]
    if filtered_data.empty:
        raise HTTPException(status_code=404, detail="No data available for the given date range.")
    
    # Plot the data
    plt.figure(figsize=(10, 6))
    plt.plot(filtered_data['Date'], filtered_data['Close'], label='Close Price', marker='o')
    plt.plot(filtered_data['Date'], filtered_data['200d_MA'], label='200-Day Moving Average', linestyle='--')
    plt.title("Closing Price and 200-Day Moving Average")
    plt.xlabel("Date")
    plt.ylabel("Price")
    plt.legend()
    plt.grid()
    plt.tight_layout()

    # Save the plot to a temporary file
    file_path = "temp_plot.png"
    plt.savefig(file_path)
    plt.close()

    # Return the plot as a file response
    return FileResponse(file_path, media_type="image/png", filename="plot.png")

# To run the app, use: uvicorn app:app --reload
