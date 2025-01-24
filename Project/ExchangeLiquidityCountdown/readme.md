
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