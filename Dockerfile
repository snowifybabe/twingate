# Use the official Twingate Connector image
FROM twingate/connector:latest

# Install python3 for the dummy server and supervisor to manage processes
RUN apt-get update && apt-get install -y \
    python3 \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy our supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Twingate requires these environment variables to function
# You will provide these at runtime
ENV TWINGATE_NETWORK=""
ENV TWINGATE_ACCESS_TOKEN=""
ENV TWINGATE_REFRESH_TOKEN=""

# Expose the dummy server port
EXPOSE 8080

# Start Supervisor (which starts both the dummy server and Twingate)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
