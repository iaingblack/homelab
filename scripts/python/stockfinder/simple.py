import yfinance as yf

def get_stock_info(ticker):
    # Get stock data
    ticker_data = yf.Ticker(ticker).info

    print(f"MSFT Stock Information:")
    for key, value in ticker_data.items():
        if key != "regularMarketPrice":
            print(f"{key.capitalize()}: {value}")

get_stock_info("MSFT")