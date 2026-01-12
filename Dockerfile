# --- Stage 1: Get the Twingate Binary ---
FROM twingate/connector:latest AS twingate-source

# --- Stage 2: Build the Actual Runner ---
FROM debian:bookworm-slim

# 1. Install Python and Supervisor (Standard way)
RUN apt-get update && apt-get install -y \
    python3 \
    supervisor \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy the Twingate connector binaries from the official image
# Twingate stores its binaries in /usr/bin/
COPY --from=twingate-source /usr/bin/twingate-connector* /usr/bin/

# 3. Setup Supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 4. Set Environment Variables
ENV TWINGATE_NETWORK=""
ENV TWINGATE_ACCESS_TOKEN=""
ENV TWINGATE_REFRESH_TOKEN=""

# 5. Launch using Supervisor
# We use the shell form here because Debian actually has a shell!
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
