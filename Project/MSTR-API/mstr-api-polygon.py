from fastapi import FastAPI, HTTPException
from polygon import RESTClient
import os

app = FastAPI()

# Ensure your Polygon.io API key is set as an environment variable
API_KEY = os.getenv("POLYGON_API_KEY")
if not API_KEY:
    raise ValueError("Please set the POLYGON_API_KEY environment variable.")

client = RESTClient(API_KEY)

@app.get("/stock/{stock_symbol}")
async def get_stock_price(stock_symbol: str):
    """
    Retrieve the latest price of the given stock symbol using Polygon.io.
    """
    try:
        # Fetch the latest trade for the stock symbol
        trade = client.get_last_trade(stock_symbol)
        return {"symbol": stock_symbol, "price": trade.price}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
