import requests
import yfinance as yf

def get_bitcoin_price():
    try:
        # Fetch the current Bitcoin price from CoinDesk API
        response = requests.get('https://api.coindesk.com/v1/bpi/currentprice/BTC.json')
        data = response.json()
        price_usd = data['bpi']['USD']['rate_float']
        return price_usd
    except Exception as e:
        print(f"Error fetching Bitcoin price: {e}")
        return None

def get_mstr_stock_price():
    try:
        # Fetch the current stock price of MSTR from Yahoo Finance
        stock = yf.Ticker('MSTR')
        data = stock.history(period='1d')
        if data.empty:
            print("Invalid ticker symbol or no data available.")
            return None
        price = data['Close'].iloc[-1]
        return price
    except Exception as e:
        print(f"Error fetching MSTR stock price: {e}")
        return None

def get_mstr_btc_holdings():
    # As of September 2021, MicroStrategy held approximately 114,042 Bitcoins.
    # Update this number with the latest holdings for accuracy.
    btc_holdings = 114042  # Replace with the latest number if available
    return btc_holdings

def get_mstr_shares_outstanding():
    try:
        # Fetch the number of shares outstanding from Yahoo Finance
        stock = yf.Ticker('MSTR')
        shares_outstanding = stock.info['sharesOutstanding']
        return shares_outstanding
    except Exception as e:
        print(f"Error fetching shares outstanding: {e}")
        return None

def main():
    btc_price = get_bitcoin_price()
    mstr_stock_price = get_mstr_stock_price()
    mstr_btc_holdings = get_mstr_btc_holdings()
    shares_outstanding = get_mstr_shares_outstanding()

    if None in (btc_price, mstr_stock_price, shares_outstanding):
        print("Could not retrieve all necessary data.")
        return

    # Calculate the total value of MicroStrategy's Bitcoin holdings
    total_btc_value = btc_price * mstr_btc_holdings

    # Calculate the Bitcoin value per MSTR share
    btc_value_per_share = total_btc_value / shares_outstanding

    print(f"Current Bitcoin Price (USD): ${btc_price:,.2f}")
    print(f"Current MSTR Stock Price (USD): ${mstr_stock_price:,.2f}")
    print(f"MicroStrategy's Bitcoin Holdings: {mstr_btc_holdings:,} BTC")
    print(f"MicroStrategy's Total Bitcoin Value: ${total_btc_value:,.2f}")
    print(f"Bitcoin Value Per MSTR Share: ${btc_value_per_share:,.2f}")

    # Compare MSTR stock price to Bitcoin value per share
    print("\nComparison:")
    if mstr_stock_price > btc_value_per_share:
        print(f"MSTR stock is trading at a premium of ${(mstr_stock_price - btc_value_per_share):,.2f} per share over its Bitcoin holdings.")
    else:
        print(f"MSTR stock is trading at a discount of ${(btc_value_per_share - mstr_stock_price):,.2f} per share compared to its Bitcoin holdings.")

if __name__ == "__main__":
    main()
