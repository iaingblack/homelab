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
    # Update this number with the latest holdings for accuracy.
    btc_holdings = 386700  # Replace with the latest number if available
    return btc_holdings


def get_mstr_total_spent_on_btc():
    # Update this number with the latest holdings for accuracy.
    total_spent_on_btc = 21949478700  # Replace with the latest number if available
    return total_spent_on_btc


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
    print(f"MicroStrategy's Bitcoin Holdings Total : {mstr_btc_holdings:,} BTC ({(mstr_btc_holdings/21000000)*100:,.2f}%)")
    print(f"Bitcoin Value Per MSTR Share: ${btc_value_per_share:,.2f}")
    print(f"Average Price MSTR Paid Per Bitcoin: ${get_mstr_total_spent_on_btc()/mstr_btc_holdings:,.2f}")
    print(f"Total Profit On Bitcoin Holdings as a multiple of the average price: {(btc_price/(get_mstr_total_spent_on_btc()/mstr_btc_holdings)):,.2f}x")
    print(f"Current Valuation of MSTR's Bitcoin Holdings: ${total_btc_value:,.2f}")
    print(f"Current MSTR Valuation: ${mstr_stock_price * shares_outstanding:,.2f}")
    print(f"Current value of MSTR vs Bitcoin Holdings: {(mstr_stock_price * shares_outstanding) / total_btc_value:,.2f}x")

    # Compare MSTR stock price to Bitcoin value per share
    print("\nComparison:")
    if mstr_stock_price > btc_value_per_share:
        print(f"MSTR stock (${(mstr_stock_price):,.2f}) is trading at ${(mstr_stock_price - btc_value_per_share):,.2f} per share over its Bitcoin (${btc_price:,.2f}) holdings. Or, {(mstr_stock_price / btc_value_per_share):,.2f}x. Price should be ${btc_value_per_share:,.2f}")
    else:
        print(f"MSTR stock is trading at a discount of ${(btc_value_per_share - mstr_stock_price):,.2f} per share compared to its Bitcoin holdings.")

if __name__ == "__main__":
    main()
