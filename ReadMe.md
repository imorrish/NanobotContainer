Project Goal: Safe agent to automate some 365 taks as an alternative to PowerPlatform or Copilot
Project status: Testing and debugging

1. Build the image

docker build -f dockerfile -t nanobot:local .

2. Persisted storage + config (what you must edit)

Nanobot writes its runtime config to `~/.nanobot/config.json` *inside the container*.
If you don’t mount that path, your changes will be lost when the container is recreated.

Create two persisted mounts:

- `/data` (Nanobot workspace + any files the agent creates)
- `/home/nanobot/.nanobot` (Nanobot config directory)

Example (bind mounts; Ubuntu bash):

```bash
mkdir -p ./data ./nanobot-config
```

Then, edit the persisted config file on your host:

- `./nanobot-config/config.json` (this will be mounted to `/home/nanobot/.nanobot/config.json`)

Fields you typically need to edit:

- `providers.openai.apiKey`: set to any value (LiteLLM proxy doesn’t require a real key for Ollama, but Nanobot expects one)
- `agents.defaults.model`: must match the `model_name` in `litellm_config.yaml` (default in this repo is `gpt-4`)
- `agents.defaults.workspace`: keep as `/data/workspace` unless you also change the `/data` mount

Important:

- Keep `providers.openai.apiBase` pointing to the LiteLLM proxy *inside the container*: `http://localhost:4000/v1`
  (do not set this to `host.docker.internal`; Nanobot and LiteLLM run in the same container)


3. Run the container - ollama in docker

Ubuntu bash:

```bash
docker run -d \
  -p 8000:8000 \
  -p 4000:4000 \
  -v "$(pwd)/data:/data" \
  -v "$(pwd)/nanobot-config:/home/nanobot/.nanobot" \
  --add-host=host.docker.internal:host-gateway \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -e LITELLM_MASTER_KEY='pass@word!' \
  nanobot:local

# OR - ollama remote
docker run -d \
  -p 8000:8000 \
  -p 4000:4000 \
  -v "$(pwd)/data:/data" \
  -v "$(pwd)/nanobot-config:/home/nanobot/.nanobot" \
  -e OLLAMA_BASE_URL=http://192.168.1.97:11434 \
  -e LITELLM_MASTER_KEY='pass@word!' \
  nanobot:local
```

Windows PowerShell (`pwsh`): (PowerShell uses backtick for line continuation)

```powershell
docker run -d `
  -p 8000:8000 `
  -p 4000:4000 `
  -v "${PWD}/data:/data" `
  -v "${PWD}/nanobot-config:/home/nanobot/.nanobot" `
  --add-host=host.docker.internal:host-gateway `
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 `
  -e LITELLM_MASTER_KEY='pass@word!' `
  nanobot:local

# OR - ollama remote
docker run -d `
  -p 8000:8000 `
  -p 4000:4000 `
  -v "${PWD}/data:/data" `
  -v "${PWD}/nanobot-config:/home/nanobot/.nanobot" `
  -e OLLAMA_BASE_URL=http://192.168.1.97:11434 `
  -e LITELLM_MASTER_KEY='pass@word!' `
  nanobot:local
```

Troubleshoot (if container exits)

docker ps -a --last 5
docker logs <container_id>

Troubleshoot LiteLLM health (with master key)

- Ubuntu bash:
  `curl -fsS -H "Authorization: Bearer $LITELLM_MASTER_KEY" http://localhost:4000/health`
- Windows PowerShell (`pwsh`): use `curl.exe` (PowerShell's `curl` is an alias)
  `curl.exe -fsS -H "Authorization: Bearer $env:LITELLM_MASTER_KEY" http://localhost:4000/health`

M365 Agents Toolkit MCP server

- This image includes Node.js/npm and installs `@microsoft/m365agentstoolkit-mcp`.
- The container auto-generates `~/.nanobot/config.json` (inside the container) with an MCP server entry that runs:
  `npx -y @microsoft/m365agentstoolkit-mcp@latest server start`

Zoom MCP server

- This image also installs `zoom-mcp` (Python MCP server).
- To use it, pass these env vars when running the container:
  - `ZOOM_API_KEY`
  - `ZOOM_API_SECRET`
  - `ZOOM_ACCOUNT_ID`
