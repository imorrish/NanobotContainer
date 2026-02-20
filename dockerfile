FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_SYSTEM_PYTHON=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    nodejs \
    npm \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user and persistent data mount point
# (Debian/Ubuntu syntax; Alpine's `adduser -D` flags don't apply here.)
RUN adduser --disabled-password --gecos "" \
    --home /home/nanobot --shell /bin/bash nanobot \
    && mkdir -p /data /home/nanobot/.nanobot \
    && chown -R nanobot:nanobot /data /home/nanobot

# Install UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Clone Nanobot
RUN git clone https://github.com/HKUDS/nanobot.git .

# Install Nanobot dependencies
RUN uv pip install --system .

# Install LiteLLM with proxy support
RUN uv pip install --system 'litellm[proxy]'

# (Optional) Preinstall MCP server package so first run is faster/offline-friendlier.
RUN npm install -g @microsoft/m365agentstoolkit-mcp@latest

# Copy config and entrypoint
COPY litellm_config.yaml .
COPY start.sh .
RUN chmod +x start.sh

EXPOSE 8000 4000

VOLUME ["/data"]

USER nanobot
WORKDIR /home/nanobot

ENTRYPOINT ["/app/start.sh"]
CMD ["gateway", "-p", "8000"]