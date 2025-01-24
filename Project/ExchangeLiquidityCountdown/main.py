from fastapi import FastAPI
from fastapi.responses import HTMLResponse
import time

app = FastAPI()

# --------------------------------------------------------------------------
# 1) Helper Functions
# --------------------------------------------------------------------------

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

# --------------------------------------------------------------------------
# 2) Countdown State (Single Real-Time Balance)
# --------------------------------------------------------------------------

class CountdownState:
    """
    Stores:
      - initial_balance (BTC on exchanges at server start)
      - baseline_outflow (BTC net outflow per day, used for real-time countdown)
      - start_time (when the countdown began)
    
    The get_current_balance() method calculates how much BTC
    should remain right now, based on how many seconds have elapsed
    and the baseline_outflow rate.
    """
    def __init__(self, initial_balance: float, baseline_outflow: float):
        self.initial_balance = initial_balance
        self.baseline_outflow = baseline_outflow
        self.start_time = time.time()  # capture the moment we start

    def get_current_balance(self) -> float:
        """
        Computes how much BTC should be left right now, based on
        how many seconds have elapsed since start_time, at a constant
        baseline_outflow rate.
        """
        elapsed_seconds = time.time() - self.start_time
        btc_per_second = self.baseline_outflow / 86400  # daily_outflow / 86,400
        outflow_so_far = btc_per_second * elapsed_seconds
        current_balance = self.initial_balance - outflow_so_far
        return max(0, current_balance)  # clamp at 0 if negative

# Create a global countdown state:
# - We'll pretend there's 2,000,000 BTC on exchanges
# - Draining at 1,500 BTC/day in real time
countdown_state = CountdownState(initial_balance=2_000_000, baseline_outflow=1500)

# --------------------------------------------------------------------------
# 3) Multiple Hypothetical Scenarios
# --------------------------------------------------------------------------
# Suppose we track hypothetical daily outflow rates derived from:
# "Last day", "Last week", "Last month", "Last 3 months", "Last year"
# (Fake values for demonstration)
multiple_outflows = {
    "Last Day": 1200,      # e.g., 1,200 BTC/day
    "Last Week": 1400,     # e.g., 1,400 BTC/day
    "Last Month": 1600,    # e.g., 1,600 BTC/day
    "Last 3 Months": 1800, # e.g., 1,800 BTC/day
    "Last Year": 2000      # e.g., 2,000 BTC/day
}

# --------------------------------------------------------------------------
# 4) JSON Endpoint (/countdown)
# --------------------------------------------------------------------------

@app.get("/countdown")
def get_countdown():
    """
    Returns a JSON object with:
      - The "real-time" current balance (draining at the baseline_outflow).
      - A set of hypothetical scenarios (each with a different outflow),
        showing how long it would take to reach 0 from the *current* balance.
    """
    current_balance = countdown_state.get_current_balance()

    # If baseline_outflow is 0 or negative, the real-time countdown won't go down.
    # We can still do hypothetical scenarios, though.
    
    # Prepare the result for each scenario
    scenarios_result = []
    for label, outflow_value in multiple_outflows.items():
        if outflow_value > 0:
            days_left = current_balance / outflow_value
            (yrs, mons, dys, hrs, mins, secs) = approximate_time_breakdown(days_left)
            scenario_data = {
                "label": label,
                "daily_outflow": outflow_value,
                "time_left": {
                    "years": yrs,
                    "months": mons,
                    "days": dys,
                    "hours": hrs,
                    "minutes": mins,
                    "seconds": secs
                }
            }
        else:
            scenario_data = {
                "label": label,
                "daily_outflow": outflow_value,
                "time_left": "Outflow is zero or negative; not applicable."
            }
        scenarios_result.append(scenario_data)
    
    return {
        "current_balance": current_balance,
        "baseline_outflow": countdown_state.baseline_outflow,
        "scenarios": scenarios_result
    }

# --------------------------------------------------------------------------
# 5) Auto-Updating HTML Page (Root "/")
# --------------------------------------------------------------------------

@app.get("/", response_class=HTMLResponse)
def show_countdown_html():
    """
    Displays a simple HTML page that auto-updates every second.
    It fetches JSON from /countdown and updates the DOM with multiple scenarios.
    """
    # We'll create a table for the scenario outflows and their times to zero.
    # The JavaScript will update each row with fresh data from /countdown once per second.
    
    html_content = """
    <html>
    <head>
        <title>BTC Countdown - Multiple Scenarios</title>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          table { border-collapse: collapse; margin-top: 10px; }
          th, td { border: 1px solid #ccc; padding: 8px; }
          th { background-color: #f9f9f9; }
        </style>
    </head>
    <body>
        <h1>BTC Countdown (Multiple Outflow Scenarios)</h1>
        
        <div>
            <p><strong>Real-Time Balance (draining at baseline rate):</strong> 
               <span id="currentBalance">Loading...</span> BTC</p>
            <p><strong>Baseline Daily Outflow:</strong> 
               <span id="baselineOutflow">Loading...</span> BTC/day</p>
        </div>
        
        <hr>
        
        <h2>Hypothetical Outflow Scenarios</h2>
        <table>
          <thead>
            <tr>
              <th>Scenario</th>
              <th>Outflow (BTC/day)</th>
              <th>Years</th>
              <th>Months</th>
              <th>Days</th>
              <th>Hours</th>
              <th>Minutes</th>
              <th>Seconds</th>
            </tr>
          </thead>
          <tbody id="scenarioTableBody">
            <!-- We'll dynamically populate this with JS -->
          </tbody>
        </table>
        
        <p><em>The page updates automatically every second (via JavaScript).</em></p>
        
        <script>
            function updateCountdown() {
                fetch('/countdown')
                    .then(response => response.json())
                    .then(data => {
                        // 1) Update the real-time balance and baseline outflow
                        document.getElementById('currentBalance').textContent = data.current_balance.toFixed(4);
                        document.getElementById('baselineOutflow').textContent = data.baseline_outflow.toFixed(2);
                        
                        // 2) Clear and rebuild the scenario table body
                        const tbody = document.getElementById('scenarioTableBody');
                        tbody.innerHTML = ''; // clear old rows
                        
                        data.scenarios.forEach((scenario) => {
                            const row = document.createElement('tr');
                            
                            // Scenario label
                            const cellLabel = document.createElement('td');
                            cellLabel.textContent = scenario.label;
                            row.appendChild(cellLabel);
                            
                            // Outflow
                            const cellOutflow = document.createElement('td');
                            cellOutflow.textContent = scenario.daily_outflow.toFixed(2);
                            row.appendChild(cellOutflow);
                            
                            if (typeof scenario.time_left === 'string') {
                                // If the scenario says "Outflow is zero or negative; not applicable."
                                // Just fill the rest of the cells with '-'
                                for (let i = 0; i < 6; i++) {
                                    const cell = document.createElement('td');
                                    cell.textContent = '-';
                                    row.appendChild(cell);
                                }
                            } else {
                                // Years
                                const cellYears = document.createElement('td');
                                cellYears.textContent = scenario.time_left.years;
                                row.appendChild(cellYears);
                                
                                // Months
                                const cellMonths = document.createElement('td');
                                cellMonths.textContent = scenario.time_left.months;
                                row.appendChild(cellMonths);
                                
                                // Days
                                const cellDays = document.createElement('td');
                                cellDays.textContent = scenario.time_left.days;
                                row.appendChild(cellDays);
                                
                                // Hours
                                const cellHours = document.createElement('td');
                                cellHours.textContent = scenario.time_left.hours;
                                row.appendChild(cellHours);
                                
                                // Minutes
                                const cellMinutes = document.createElement('td');
                                cellMinutes.textContent = scenario.time_left.minutes;
                                row.appendChild(cellMinutes);
                                
                                // Seconds
                                const cellSeconds = document.createElement('td');
                                cellSeconds.textContent = scenario.time_left.seconds;
                                row.appendChild(cellSeconds);
                            }
                            
                            tbody.appendChild(row);
                        });
                        
                    })
                    .catch(error => {
                        console.error('Error fetching countdown data:', error);
                    });
            }
            
            // Fetch new data every second
            setInterval(updateCountdown, 1000);
            // Fetch immediately on page load
            updateCountdown();
        </script>
    </body>
    </html>
    """
    
    return html_content
