import logging
import time
from opentelemetry import metrics, trace
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import SimpleSpanProcessor
from opentelemetry.sdk.resources import Resource
from opentelemetry._logs import set_logger_provider
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc._log_exporter import OTLPLogExporter
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor

# Set up resource for OpenTelemetry
resource = Resource(attributes={
    "service.name": "simple-telemetry-demo"
})

# Configure local logging (for console output)
local_logger = logging.getLogger("local_logger")
local_logger.setLevel(logging.INFO)
console_handler = logging.StreamHandler()  # Outputs to console
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
local_logger.addHandler(console_handler)

# Configure Metrics (OTLP)
metric_exporter = OTLPMetricExporter(endpoint="localhost:4317", insecure=True)
metric_reader = PeriodicExportingMetricReader(metric_exporter)
meter_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter("example-meter")
request_counter = meter.create_counter(
    name="requests_total",
    description="Total number of requests",
    unit="1"
)

# Configure Tracing (OTLP)
trace_exporter = OTLPSpanExporter(endpoint="localhost:4317", insecure=True)
span_processor = SimpleSpanProcessor(trace_exporter)
tracer_provider = TracerProvider(resource=resource)
tracer_provider.add_span_processor(span_processor)
trace.set_tracer_provider(tracer_provider)
tracer = trace.get_tracer("example-tracer")

# Configure OpenTelemetry Logging (OTLP)
log_exporter = OTLPLogExporter(endpoint="localhost:4317", insecure=True)
logger_provider = LoggerProvider(resource=resource)
logger_provider.add_log_record_processor(BatchLogRecordProcessor(log_exporter))
set_logger_provider(logger_provider)
otel_handler = LoggingHandler()
otel_logger = logging.getLogger("otel_logger")
otel_logger.addHandler(otel_handler)
otel_logger.setLevel(logging.INFO)

# Example function to demonstrate telemetry with local and OTLP logging
def process_request(request_id):
    # Add to metric
    request_counter.add(1, {"request_id": str(request_id)})
    
    # Local log
    local_logger.info(f"Starting local processing of request {request_id}")
    
    # Create a trace and OTLP log
    with tracer.start_as_current_span("process-request") as span:
        span.set_attribute("request_id", request_id)
        
        # OTLP log (sent to Collector)
        otel_logger.info(f"Processing request {request_id} (sent to OTLP)")
        
        # Simulate some work
        span.add_event("Starting request processing")
        local_logger.info(f"Simulating work for request {request_id}")
        print(f"Processing request {request_id}")
        time.sleep(0.5)  # Simulate processing time
        span.add_event("Finished request processing")
        
        # Local log
        local_logger.info(f"Completed local processing of request {request_id}")

# Main execution
if __name__ == "__main__":
    local_logger.info("Starting telemetry demo...")
    print("Starting telemetry demo...")
    
    # Process a few requests
    for i in range(3):
        process_request(i)
    
    # Give some time for OTLP export
    time.sleep(2)
    local_logger.info("Demo complete!")
    print("Demo complete!")