#!/bin/bash
set -e

echo "Starting LiteLLM Proxy..."
# Start LiteLLM pointing to the config
litellm --config /app/litellm_config.yaml --port 4000 &

# Wait for proxy to be ready
sleep 5

# Configure Nanobot to use the local proxy
export OPENAI_BASE_URL=http://localhost:4000/v1
export OPENAI_API_KEY=fake-key # LiteLLM needs a placeholder key

echo "Starting Nanobot..."
# Adjust 'main.py' if the repo entry point is different
exec python "$@"