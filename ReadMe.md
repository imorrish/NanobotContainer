Project Goal: Safe agent to automate some 365 taks as an alternative to PowerPlatform or Copilot
Project status: Testing and debugging

1. Build the image

docker build -f dockerfile -t nanobot:local .

(If you prefer the image name `nanobot-ollama`, build with `-t nanobot-ollama` and use that name in `docker run`.)

2. Run the container - ollama in docker

docker run -d \
  -p 8000:8000 \
  -p 4000:4000 \
  --add-host=host.docker.internal:host-gateway \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  nanobot:local

OR - ollama remote

docker run -d \
  -p 8000:8000 \
  -p 4000:4000 \
  -e OLLAMA_BASE_URL=http://192.168.1.97:11434 \
  nanobot:local

Troubleshoot (if container exits)

docker ps -a --last 5
docker logs <container_id>

M365 Agents Toolkit MCP server

- This image includes Node.js/npm and installs `@microsoft/m365agentstoolkit-mcp`.
- The container auto-generates `~/.nanobot/config.json` (inside the container) with an MCP server entry that runs:
  `npx -y @microsoft/m365agentstoolkit-mcp@latest server start`