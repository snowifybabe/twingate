# Use the official Twingate Connector as the base
FROM twingate/connector:latest

# Switch to root to install python for the dummy server
USER root
RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

# Create a simple entrypoint script to run both processes
RUN echo '#!/bin/bash \n\
# Start a dummy web server on port 8080 in the background \n\
# This provides the "route" Koyeb needs to monitor for traffic \n\
python3 -m http.server 8080 & \n\
\n\
# Start the Twingate connector (the primary process) \n\
# We use exec to ensure signals (like SIGTERM) are passed correctly \n\
exec /usr/bin/connectorctl start' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Expose the port for Koyeb's route
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
