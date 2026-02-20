Project status: Testing and debugging

Build the image

docker build -f dockerfile -t nanobot:local .

Run the container - ollama in docker

docker run -d \
  -p 8000:8000 \
  --add-host=host.docker.internal:host-gateway \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  nanobot-ollama

OR - olama remote

docker run -d \
  -p 8000:8000 \
  -e OLLAMA_BASE_URL=http://192.168.1.50:11434 \
  nanobot-ollama