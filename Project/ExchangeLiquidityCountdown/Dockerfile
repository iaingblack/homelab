# Use a minimal Python image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy requirements and install them
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the entire application into the container
COPY . .

# Expose port 80 for the container
EXPOSE 80

# Run Uvicorn when container starts (replace 'main:app' if your entry point differs)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
