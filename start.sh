#!/bin/bash
set -e

: "${LITELLM_MASTER_KEY:?LITELLM_MASTER_KEY is required to use LiteLLM Admin UI (set it via -e LITELLM_MASTER_KEY=...)}"

echo "Starting LiteLLM Proxy..."
litellm --config /app/litellm_config.yaml --port 4000 &

# Wait for proxy to be ready (best-effort)
for i in $(seq 1 30); do
    if curl -fsS \
        -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
        http://localhost:4000/health >/dev/null 2>&1; then
        break
    fi
    sleep 1
done
# Configure Nanobot/OpenAI to use the local proxy
export OPENAI_API_KEY=${OPENAI_API_KEY:-$LITELLM_MASTER_KEY}
export OPENAI_BASE_URL=${OPENAI_BASE_URL:-http://localhost:4000/v1}

# Ensure nanobot config exists and points to the proxy
CONFIG_DIR=${HOME:-/root}/.nanobot
CONFIG_FILE="$CONFIG_DIR/config.json"
DATA_DIR=${NANOBOT_DATA_DIR:-/data}
WORKSPACE_DIR=${NANOBOT_WORKSPACE_DIR:-"$DATA_DIR/workspace"}

mkdir -p "$CONFIG_DIR" "$DATA_DIR" "$WORKSPACE_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
	cat > "$CONFIG_FILE" <<'JSON'
{
	"providers": {
		"openai": {
			"apiKey": "12345",
			"apiBase": "http://localhost:4000/v1"
		}
	},
	"agents": {
		"defaults": {
			"workspace": "/data/workspace",
			"model": "gpt-oss:20b"
		}
	},
	"tools": {
		"mcpServers": {
			"m365agentstoolkit": {
				"command": "npx",
				"args": [
					"-y",
					"@microsoft/m365agentstoolkit-mcp@latest",
					"server",
					"start"
				]
			},
			"zoom": {
				"command": "zoom-mcp",
				"args": [
					"--log-level",
					"INFO"
				]
			}
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