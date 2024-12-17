from fastapi import FastAPI, HTTPException
import yfinance as yf

app = FastAPI()

@app.get("/stock/{stock_symbol}")
async def get_stock_price(stock_symbol: str):
    """
    Retrieve the price of the given stock symbol using Yahoo Finance.
    """
    try:
        # Use yfinance to fetch stock data
        stock = yf.Ticker(stock_symbol)
        stock_info = stock.history(period="1d")
        
        # Ensure data is available
        if stock_info.empty:
            raise HTTPException(status_code=404, detail="Stock not found")
        
        # Extract the latest closing price
        latest_close = stock_info["Close"].iloc[-1]
        return {"symbol": stock_symbol, "price": latest_close}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
