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
countdown_state = CountdownState(initial_balance=2_173_110, daily_outflow=1500)

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
# 4) Auto-Updating HTML Page (Root)
# -------------------------------

@app.get("/", response_class=HTMLResponse)
def show_countdown_html():
    """
    Displays a simple HTML page that auto-updates every second.
    It fetches JSON from /countdown and updates the DOM.
    """
    # The HTML includes a script that calls fetch("/countdown") every second.
    # The JSON response is used to update the page dynamically.
    
    html_content = """
    <html>
    <head>
        <title>BTC Countdown</title>
        <meta charset="UTF-8">
    </head>
    <body>
        <h1>BTC Countdown</h1>
        
        <p><strong>Balance Remaining:</strong> <span id="balance">Loading...</span> BTC</p>
        
        <p><strong>Approx Time Until 0:</strong></p>
        <ul>
            <li><strong>Years:</strong> <span id="years"></span></li>
            <li><strong>Months:</strong> <span id="months"></span></li>
            <li><strong>Days:</strong> <span id="days"></span></li>
            <li><strong>Hours:</strong> <span id="hours"></span></li>
            <li><strong>Minutes:</strong> <span id="minutes"></span></li>
            <li><strong>Seconds:</strong> <span id="seconds"></span></li>
        </ul>
        
        <p><em>The page updates automatically every second.</em></p>
        
        <script>
            function fetchCountdown() {
                fetch('/countdown')
                    .then(response => response.json())
                    .then(data => {
                        // If there's no net outflow, we display a special message
                        if (typeof data.time_left === 'string') {
                            // "No net outflow" scenario
                            document.getElementById('balance').textContent = data.balance.toFixed(4);
                            document.getElementById('years').textContent = '-';
                            document.getElementById('months').textContent = '-';
                            document.getElementById('days').textContent = '-';
                            document.getElementById('hours').textContent = '-';
                            document.getElementById('minutes').textContent = '-';
                            document.getElementById('seconds').textContent = '-';
                        } else {
                            // Normal countdown scenario
                            document.getElementById('balance').textContent = data.balance.toFixed(4);
                            document.getElementById('years').textContent = data.time_left.years;
                            document.getElementById('months').textContent = data.time_left.months;
                            document.getElementById('days').textContent = data.time_left.days;
                            document.getElementById('hours').textContent = data.time_left.hours;
                            document.getElementById('minutes').textContent = data.time_left.minutes;
                            document.getElementById('seconds').textContent = data.time_left.seconds;
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching countdown:', error);
                    });
            }
            
            // Call fetchCountdown() every second
            setInterval(fetchCountdown, 1000);
            // Also fetch immediately on page load
            fetchCountdown();
        </script>
    </body>
    </html>
    """
    
    return html_content
