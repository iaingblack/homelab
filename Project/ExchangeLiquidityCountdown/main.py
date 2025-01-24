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
# 2) Countdown State (Real-Time Balance)
# --------------------------------------------------------------------------

class CountdownState:
    """
    Stores:
      - initial_balance (BTC at server start)
      - baseline_outflow (BTC/day) for the real-time countdown
      - start_time (when the countdown began)
    """
    def __init__(self, initial_balance: float, baseline_outflow: float):
        self.initial_balance = initial_balance
        self.baseline_outflow = baseline_outflow
        self.start_time = time.time()  # capture the moment we start

    def get_current_balance(self) -> float:
        """
        How much BTC remains right now, given the baseline outflow,
        based on how many seconds have elapsed since start_time.
        """
        elapsed_seconds = time.time() - self.start_time
        btc_per_second = self.baseline_outflow / 86400  # daily_outflow / 86,400
        outflow_so_far = btc_per_second * elapsed_seconds
        current_balance = self.initial_balance - outflow_so_far
        return max(0, current_balance)

# --------------------------------------------------------------------------
# 3) Global Countdown State
#    - You requested an initial BTC balance of 2,174,000.
#    - We'll keep a baseline outflow of 1,500 BTC/day for the "real-time" drain.
# --------------------------------------------------------------------------

countdown_state = CountdownState(
    initial_balance=2_174_000,  # 2,174,000 BTC
    baseline_outflow=1500       # Example baseline outflow
)

# --------------------------------------------------------------------------
# 4) Multiple Outflow Scenarios (Fake Data)
#    As per your request:
# --------------------------------------------------------------------------

multiple_outflows = {
    "Last Day": 1200,
    "Last Week": 1285,
    "Last Month": 3000,
    "Last 3 Months": 2802,
    "Last Year": 1493
}

# --------------------------------------------------------------------------
# 5) JSON Endpoint (/countdown)
# --------------------------------------------------------------------------

@app.get("/countdown")
def get_countdown():
    """
    Returns a JSON structure with:
      - current_balance (real-time)
      - baseline_outflow
      - scenarios: array of:
          { label, daily_outflow, time_left: {...}, days_left }
    """
    current_balance = countdown_state.get_current_balance()
    
    # Build scenario data
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
                },
                "days_left": days_left  # for chart plotting
            }
        else:
            scenario_data = {
                "label": label,
                "daily_outflow": outflow_value,
                "time_left": "Outflow <= 0; not applicable.",
                "days_left": 0
            }
        scenarios_result.append(scenario_data)
    
    return {
        "current_balance": current_balance,
        "baseline_outflow": countdown_state.baseline_outflow,
        "scenarios": scenarios_result
    }

# --------------------------------------------------------------------------
# 6) HTML Page (Root "/") 
#    - Renders the chart only ONCE on page load
#    - The table data updates every second, but NOT the chart
# --------------------------------------------------------------------------

@app.get("/", response_class=HTMLResponse)
def show_countdown_html():
    """
    Displays an HTML page that:
      - Builds the chart once on page load (X-axis in years, single decimal)
      - Continues to update only the table every second (NOT the chart).
    """
    html_content = """
    <html>
    <head>
        <title>BTC Countdown - Chart One-Time, Table Updates</title>
        <meta charset="UTF-8">
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; background-color: lightgray; }
          table { border-collapse: collapse; margin-top: 10px; }
          th, td { border: 1px solid #000; padding: 8px; }
          th { background-color: #f9f9f9; }
          #chartContainer { margin-top: 40px; width: 800px; }
          #forecastChart { width: 100%; height: 400px; }
        </style>
        <!-- Include Chart.js from a CDN -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    </head>
    <body>
        <h1>BTC Countdown (Chart Once, Table Auto-Updates)</h1>
        
        <div>
            <p><strong>Real-Time Balance (baseline rate):</strong> 
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
            <!-- We'll dynamically fill this with JS -->
          </tbody>
        </table>
        
        <div id="chartContainer">
            <canvas id="forecastChart"></canvas>
        </div>
        
        <p>
          <em>The chart is rendered once at page load (snapshot). 
              The table refreshes every second, but the chart does not change.</em>
        </p>
        
        <script>
            let forecastChart = null;

            // ----------------------------------------------------------------
            // 1) Build the chart ONLY ONCE using the data at page load
            // ----------------------------------------------------------------
            function buildChart(snapshotData) {
                // We convert the scenario's days_left to years, then produce 
                // points for x-values in 0.1-year increments, up to the max.
                
                // Find maxDays among scenarios
                let maxDays = 0;
                snapshotData.scenarios.forEach(s => {
                    if (s.days_left > maxDays) {
                        maxDays = s.days_left;
                    }
                });
                const maxYears = maxDays / 365;  // days -> years
                const step = 0.1;                // step for x-axis (in years)
                
                // Prepare color palette
                const colors = [
                    "rgb(255, 99, 132)",
                    "rgb(54, 162, 235)",
                    "rgb(255, 206, 86)",
                    "rgb(75, 192, 192)",
                    "rgb(153, 102, 255)",
                    "rgb(255, 159, 64)"
                ];
                let colorIndex = 0;

                // Build scenario datasets
                const scenarioDatasets = [];
                
                snapshotData.scenarios.forEach(scenario => {
                    if (scenario.daily_outflow > 0) {
                        const scenarioColor = colors[colorIndex % colors.length];
                        colorIndex++;
                        
                        const points = [];
                        // For x in 0.0 to maxYears in increments of 0.1
                        const stepsCount = Math.floor(maxYears / step);
                        for (let i = 0; i <= stepsCount; i++) {
                            const yearVal = i * step;
                            const daysVal = yearVal * 365;
                            let btcLeft = snapshotData.current_balance 
                                          - scenario.daily_outflow * daysVal;
                            if (btcLeft < 0) btcLeft = 0;
                            points.push(btcLeft);
                        }
                        
                        scenarioDatasets.push({
                            label: scenario.label + ` (${scenario.daily_outflow} BTC/day)`,
                            data: points,
                            borderColor: scenarioColor,
                            backgroundColor: scenarioColor,
                            fill: false,
                            tension: 0.1
                        });
                    }
                });

                // Build X-axis labels in years, one decimal place
                const xLabels = [];
                const stepsCount = Math.floor(maxYears / step);
                for (let i = 0; i <= stepsCount; i++) {
                    const yearVal = (i * step).toFixed(1);  // e.g. "0.0", "0.1", ...
                    xLabels.push(yearVal);
                }

                const ctx = document.getElementById('forecastChart').getContext('2d');
                forecastChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: xLabels,
                        datasets: scenarioDatasets
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            x: {
                                title: {
                                    display: true,
                                    text: 'Years from Now (Snapshot)'
                                }
                            },
                            y: {
                                title: {
                                    display: true,
                                    text: 'BTC Remaining'
                                },
                                beginAtZero: true
                            }
                        },
                        plugins: {
                            title: {
                                display: true,
                                text: 'Forecasted Balance by Scenario (One-Time Chart)'
                            }
                        }
                    }
                });
            }

            // ----------------------------------------------------------------
            // 2) Update the TABLE every second (NOT the chart)
            // ----------------------------------------------------------------
            function updateTableData() {
                fetch('/countdown')
                    .then(response => response.json())
                    .then(data => {
                        // Update real-time balance & baseline outflow
                        document.getElementById('currentBalance').textContent =
                            data.current_balance.toFixed(4);
                        document.getElementById('baselineOutflow').textContent =
                            data.baseline_outflow.toFixed(2);
                        
                        // Update scenario table
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
                                // e.g. "Outflow <= 0; not applicable."
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

            // ----------------------------------------------------------------
            // 3) On Page Load: 
            //    a) Fetch data to build the chart once
            //    b) Start the table updates every second
            // ----------------------------------------------------------------
            fetch('/countdown')
                .then(response => response.json())
                .then(data => {
                    // Build the chart one time
                    buildChart(data);
                    // Then start table updates
                    updateTableData(); // do one update now
                    setInterval(updateTableData, 1000); // update table every second
                })
                .catch(error => {
                    console.error('Error fetching countdown data (initial):', error);
                });
        </script>
    </body>
    </html>
    """

    return html_content
