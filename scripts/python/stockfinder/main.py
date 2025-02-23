import yfinance as yf
import pandas as pd
from sqlalchemy import create_engine, Table, Column, String, Date, Float, Integer, MetaData
from sqlalchemy.dialects.postgresql import insert

# ---------------------------
# 1. Define your ticker list
# ---------------------------
# Example list of top 100 stocks (update/extend this list as needed)
# tickers = [
#     "AAPL", "MSFT", "AMZN", "GOOGL", "META", "TSLA", "BRK-B", "JPM", "JNJ", "V",
#     "WMT", "PG", "UNH", "MA", "NVDA", "HD", "DIS", "PYPL", "BAC", "VZ",
#     "ADBE", "CMCSA", "NFLX", "INTC", "KO", "T", "PFE", "MRK", "PEP", "CSCO",
#     "ABT", "CRM", "XOM", "CVX", "ACN", "COST", "MCD", "LLY", "NKE", "DHR",
#     "MDT", "NEE", "TXN", "LIN", "BMY", "HON", "UNP", "PM", "QCOM", "UPS",
#     "LOW", "IBM", "SBUX", "CAT", "AMGN", "AXP", "BLK", "NOW", "GE", "TMO",
#     "SPGI", "GILD", "DE", "ISRG", "LRCX", "FIS", "ADP", "SYK", "GM", "ZTS",
#     "PLD", "MO", "CCI", "DUK", "PNC", "BKNG", "CCI", "CL", "SHW", "APD",
#     "C", "MMC", "CI", "NSC", "FDX", "GM", "CB", "EW", "COF", "ICE",
#     "ADM", "EXC", "SO", "ECL", "PSA", "WM"
# ]

tickers = [
    "AAPL"
]

# -----------------------------------------------
# 2. Download 5 years of historical data from Yahoo
# -----------------------------------------------
# This downloads data for all tickers; the result has a multi-indexed DataFrame (date and ticker level)
data = yf.download(tickers, period="5y", group_by="ticker")

# When downloading multiple tickers, yfinance returns a DataFrame with a MultiIndex on columns.
# We'll convert it to a long-form DataFrame with one row per ticker per date.
df_list = []
for ticker in tickers:
    # Get the DataFrame for this ticker
    ticker_df = data[ticker].copy()
    ticker_df["ticker"] = ticker
    ticker_df["date"] = ticker_df.index
    df_list.append(ticker_df)

df = pd.concat(df_list).reset_index(drop=True)

# Rename columns for consistency (and lower-case them)
df = df.rename(columns={
    "Adj Close": "adj_close",
    "Open": "open",
    "High": "high",
    "Low": "low",
    "Close": "close",
    "Volume": "volume"
})

# Ensure the date column is a date object (without the time part)
df["date"] = pd.to_datetime(df["date"]).dt.date

# (Optional) Inspect the data
print(df.head())

# -------------------------------------------------------
# 3. Connect to PostgreSQL and create (or ensure) the table
# -------------------------------------------------------
# Update the connection string with your actual PostgreSQL credentials and database info.
engine = create_engine("postgresql://username:password@localhost:5432/mydatabase")

metadata = MetaData()

# Define a table with a composite primary key on (ticker, date)
stocks_table = Table(
    "stocks",
    metadata,
    Column("ticker", String, primary_key=True),
    Column("date", Date, primary_key=True),
    Column("open", Float),
    Column("high", Float),
    Column("low", Float),
    Column("close", Float),
    Column("adj_close", Float),
    Column("volume", Integer),
)

# Create the table if it does not exist
metadata.create_all(engine)

# -------------------------------------------------------
# 4. Upsert the data into the PostgreSQL database
# -------------------------------------------------------
# Convert the DataFrame to a list of dictionaries (one per row)
records = df.to_dict(orient="records")

# Prepare the insert statement with an upsert (ON CONFLICT) clause.
stmt = insert(stocks_table)
on_conflict_stmt = stmt.on_conflict_do_update(
    index_elements=["ticker", "date"],
    set_={
        "open": stmt.excluded.open,
        "high": stmt.excluded.high,
        "low": stmt.excluded.low,
        "close": stmt.excluded.close,
        "adj_close": stmt.excluded.adj_close,
        "volume": stmt.excluded.volume,
    },
)

# Execute the upsert in a transaction.
with engine.begin() as conn:
    conn.execute(on_conflict_stmt, records)

print("Data uploaded/updated successfully.")
