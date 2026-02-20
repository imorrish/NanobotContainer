#!/bin/bash
set -e

echo "Starting LiteLLM Proxy..."
# Start LiteLLM pointing to the config
litellm --config /app/litellm_config.yaml --port 4000 &

# Wait for proxy to be ready (best-effort)
for i in $(seq 1 30); do
	if curl -fsS http://localhost:4000/health >/dev/null 2>&1; then
		break
	fi
	sleep 1
done

# Configure Nanobot/OpenAI to use the local proxy
export OPENAI_API_KEY=${OPENAI_API_KEY:-fake-key}
export OPENAI_BASE_URL=${OPENAI_BASE_URL:-http://localhost:4000/v1}

# Ensure nanobot config exists and points to the proxy
CONFIG_DIR=${HOME:-/root}/.nanobot
CONFIG_FILE="$CONFIG_DIR/config.json"
WORKSPACE_DIR="$CONFIG_DIR/workspace"

mkdir -p "$CONFIG_DIR" "$WORKSPACE_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
	cat > "$CONFIG_FILE" <<'JSON'
{
	"providers": {
		"openai": {
			"apiKey": "fake-key",
			"apiBase": "http://localhost:4000/v1"
		}
	},
	"agents": {
		"defaults": {
			"model": "gpt-4"
		}
	},
	"gateway": {
		"host": "0.0.0.0",
		"port": 8000
	}
}
JSON
fi

echo "Starting Nanobot..."
exec nanobot "$@"