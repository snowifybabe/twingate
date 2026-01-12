# --- Stage 1: Builder ---
FROM debian:bookworm-slim AS builder
RUN apt-get update && apt-get install -y \
    python3-minimal \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# --- Stage 2: Final Image ---
FROM twingate/connector:latest

# Copy python and supervisor from the builder
COPY --from=builder /usr/bin/python3* /usr/bin/
COPY --from=builder /usr/lib/python3* /usr/lib/
COPY --from=builder /usr/bin/supervisord /usr/bin/supervisord
COPY --from=builder /usr/bin/supervisorctl /usr/bin/supervisorctl
COPY --from=builder /etc/supervisor /etc/supervisor

# Copy your config (make sure supervisord.conf is in your local folder)
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Twingate credentials (to be passed at runtime)
ENV TWINGATE_NETWORK=""
ENV TWINGATE_ACCESS_TOKEN=""
ENV TWINGATE_REFRESH_TOKEN=""

# Start Supervisor
# Since there is no shell, we must use the "exec" form (JSON array)
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
