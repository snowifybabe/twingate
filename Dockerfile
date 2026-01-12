# --- Stage 1: Get the Twingate Binary ---
FROM twingate/connector:latest AS twingate-source

# --- Stage 2: Build the Actual Runner ---
FROM debian:bookworm-slim

# Install Python and Supervisor
RUN apt-get update && apt-get install -y \
    python3 \
    supervisor \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# COPY THE CORRECT BINARY: 
# Twingate stores the main binary as /connectord in their image
COPY --from=twingate-source /connectord /usr/bin/connectord

# Copy Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set Twingate Envs (Must be provided in Koyeb Dashboard)
ENV TWINGATE_NETWORK=""
ENV TWINGATE_ACCESS_TOKEN=""
ENV TWINGATE_REFRESH_TOKEN=""

# Launch using Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

EXPOSE 8000
