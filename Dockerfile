# Use the official Twingate Connector as the base image
FROM twingate/connector:1

# Install python3 to run the dummy health server
RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

# Create a dummy health server script
RUN echo 'from http.server import BaseHTTPRequestHandler, HTTPServer \n\
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
    print("Starting health server on port 8080...") \n\
    HTTPServer(("0.0.0.0", 8080), HealthHandler).serve_forever() \n\
if __name__ == "__main__": \n\
    run()' > /health_server.py

# Create a startup script to run both processes
RUN echo '#!/bin/bash \n\
python3 /health_server.py & \n\
# Execute the original Twingate entrypoint \n\
exec /usr/bin/connectorctl run' > /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the health check port
EXPOSE 8080




ENTRYPOINT ["/entrypoint.sh"]
