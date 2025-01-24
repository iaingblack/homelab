from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import time

app = FastAPI()

# -------------------------------
# 1) Helper Functions
# -------------------------------

def approximate_time_breakdown(total_days: float):
    """
    Given a number of days (float), return the approximate time as:
    (years, months, days, hours, minutes, seconds).
    
    Using:
      - 1 year = 365 days (approx)
      - 1 month = 30 days (approx)
    """
    if total_days <= 0:
        return (0, 0, 0, 0, 0, 0)
    
    years = int(total_days // 365)
    remainder_days = total_days % 365

    months = int(remainder_days // 30)
    remainder_days = remainder_days % 30

    days = int(remainder_days)
    
    fraction_of_day = remainder_days - days
    hours = int(fraction_of_day * 24)
    fraction_of_hour = (fraction_of_day * 24) - hours
    minutes = int(fraction_of_hour * 60)
    fraction_of_minute = (fraction_of_hour * 60) - minutes
    seconds = int(fraction_of_minute * 60)
    
    return (years, months, days, hours, minutes, seconds)

# -------------------------------
# 2) Countdown State
# -------------------------------

class CountdownState:
    """
    Stores:
      - initial_balance (BTC on exchanges at server start)
      - daily_outflow (BTC net outflow per day)
      - start_time (when the countdown began)
    """
    def __init__(self, initial_balance: float, daily_outflow: float):
        self.initial_balance = initial_balance
        self.daily_outflow = daily_outflow
        self.start_time = time.time()  # capture the moment we start

    def get_current_balance(self) -> float:
        """
        Computes how much BTC should be left right now, based on
        how many seconds have elapsed since start_time, at a constant
        daily_outflow rate.
        """
        elapsed_seconds = time.time() - self.start_time
        btc_per_second = self.daily_outflow / 86400  # daily_outflow / 86,400
        outflow_so_far = btc_per_second * elapsed_seconds
        current_balance = self.initial_balance - outflow_so_far
        return max(0, current_balance)  # clamp at 0 if negative

# Create the global countdown state
countdown_state = CountdownState(initial_balance=2_000_000, daily_outflow=1500)

# -------------------------------
# 3) JSON Endpoint
# -------------------------------

@app.get("/countdown")
def get_countdown():
    """
    Returns a JSON object with:
      - current theoretical BTC balance
      - approximate time until zero (Y, M, D, H, M, S)
    """
    current_balance = countdown_state.get_current_balance()
    
    if countdown_state.daily_outflow <= 0:
        return {
            "balance": current_balance,
            "time_left": "No net outflow; countdown not applicable."
        }
    
    days_left = current_balance / countdown_state.daily_outflow
    (yrs, mons, dys, hrs, mins, secs) = approximate_time_breakdown(days_left)
    
    return {
        "balance": current_balance,
        "time_left": {
            "years": yrs,
            "months": mons,
            "days": dys,
            "hours": hrs,
            "minutes": mins,
            "seconds": secs
        }
    }

# -------------------------------
# 4) Simple HTML Page (Root)
# -------------------------------

@app.get("/", response_class=HTMLResponse)
def show_countdown_html():
    """
    Displays a simple HTML page showing the current
    BTC balance and approximate time remaining.
    """
    current_balance = countdown_state.get_current_balance()
    
    # Handle no outflow case
    if countdown_state.daily_outflow <= 0:
        return """
        <html>
        <head><title>BTC Countdown</title></head>
        <body>
            <h1>Countdown Not Applicable</h1>
            <p>No net outflow detected.</p>
        </body>
        </html>
        """
    
    days_left = current_balance / countdown_state.daily_outflow
    (yrs, mons, dys, hrs, mins, secs) = approximate_time_breakdown(days_left)
    
    # Build a simple HTML string
    html_content = f"""
    <html>
    <head>
        <title>BTC Countdown</title>
    </head>
    <body>
        <h1>BTC Countdown</h1>
        <p><strong>Balance Remaining:</strong> {current_balance:,.4f} BTC</p>
        <p><strong>Approx Time Until 0:</strong></p>
        <ul>
            <li><strong>Years:</strong> {yrs}</li>
            <li><strong>Months:</strong> {mons}</li>
            <li><strong>Days:</strong> {dys}</li>
            <li><strong>Hours:</strong> {hrs}</li>
            <li><strong>Minutes:</strong> {mins}</li>
            <li><strong>Seconds:</strong> {secs}</li>
        </ul>
        <p><em>Refresh this page to see updates.</em></p>
        
        <hr>
        <p>
        Check the JSON endpoint at <a href="/countdown">/countdown</a>
        for structured data.
        </p>
    </body>
    </html>
    """
    return html_content
