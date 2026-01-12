# Use the official Twingate Connector as the base image
FROM twingate/connector:1

# Stage 1: Build the health server binary or script
FROM python:3.11-slim as builder

# Create a simple Python health server
RUN echo 'from http.server import BaseHTTPRequestHandler, HTTPServer \n\
import os, subprocess \n\
class HealthHandler(BaseHTTPRequestHandler): \n\
    def do_GET(self): \n\
        if self.path == "/health": \n\
            self.send_response(200) \n\
            self.end_headers() \n\
            self.wfile.write(b"OK") \n\
        else: \n\
            self.send_response(404) \n\
            self.end_headers() \n\
def run(): \n\
    # Start the connector as a subprocess to keep it in the same container \n\
    subprocess.Popen(["/usr/bin/connectorctl", "run"]) \n\
    HTTPServer(("0.0.0.0", 8080), HealthHandler).serve_forever() \n\
if __name__ == "__main__": \n\
    run()' > /app/health_server.py

# Stage 2: Final Twingate Image
FROM twingate/connector:1

# Copy Python and the script from the builder stage
# (This works because the connector image is a minimal Linux environment)
COPY --from=builder /usr/local/bin/python3 /usr/local/bin/python3
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=builder /app/health_server.py /health_server.py



# Run the health server (which now manages the connector process)
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/python3", "/health_server.py"]




ENTRYPOINT ["/entrypoint.sh"]
