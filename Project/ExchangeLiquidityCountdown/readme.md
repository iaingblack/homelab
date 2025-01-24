
```bash
brew install uv
uv init
# uv add requests yfinance fastapi uvicorn polygon-api-client pandas_datareader pandas easycharts psutils easyschedule
# uv run uvicorn mstr-api-polygon:app --reload
uv add requests fastapi uvicorn 
uv run uvicorn exchangeliquiditycountdown:app --reload
```

curl http://127.0.0.1:8000/stock/mstr

export POLYGON_API_KEY=jhlkhlkljlkj


Some basic calculation values

https://www.coinglass.com/Balance

1 YEAR
2719000 - 2174000 = 545000 = 1493 per day

3 MONTHS
2429000 - 2174000 = 266933 = 2802 per day

LAST MONTH
2264000 - 2174000 = 89587 =  3000 per day

LAST WEEK
2183000 - 2174000 = 9000 = 1285 per day


Docker

docker build -t exchangeliquiditycountdow:latest ./Project/ExchangeLiquidityCountdown
docker run -p 80:80 exchangeliquiditycountdow:latest
