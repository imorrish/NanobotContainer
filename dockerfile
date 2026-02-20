FROM python:3.11-slim-bookworm

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_SYSTEM_PYTHON=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install UV
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Clone Nanobot
RUN git clone https://github.com/HKUDS/nanobot.git .

# Install Nanobot dependencies
RUN uv pip install --system .

# Install LiteLLM with proxy support
RUN uv pip install --system 'litellm[proxy]'

# Copy config and entrypoint
COPY litellm_config.yaml .
COPY start.sh .
RUN chmod +x start.sh

EXPOSE 8000 4000

ENTRYPOINT ["./start.sh"]
CMD ["gateway", "-p", "8000"]