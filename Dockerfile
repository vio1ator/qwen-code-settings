# Use the VS Code dev container base image with features
FROM mcr.microsoft.com/vscode/devcontainers/base:bookworm

# Add Node.js and Python features
# Features are installed via devcontainer.json, but we ensure they're available
RUN apt-get update && apt-get install -y python3 python3-pip nodejs npm curl wget --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Build arguments for configuration (can be overridden at build time)
ARG ENDPOINT="http://100.113.150.20:8000"
ARG MODEL="Qwen/Qwen3-Coder-Next-FP8"
ARG API_KEY="dummy"

# Install Qwen Code CLI
RUN npm install -g @qwen-code/qwen-code

# Create .qwen directory and copy settings
RUN mkdir -p ~/.qwen && \
    echo '{"modelProviders":{"openai":[{"id":"Qwen/Qwen3-Coder-Next-FP8","name":"Qwen3-Coder-Next-FP8","envKey":"OPENAI_API_KEY","baseUrl":"http://100.113.150.20:8000/v1","authType":"openai","generationConfig":{"contextWindowSize":262144}}]},"model":{"name":"Qwen/Qwen3-Coder-Next-FP8"},"security":{"auth":{"selectedType":"openai"}},"$version":3,"mcpServers":{"exa":{"httpUrl":"https://mcp.exa.ai/mcp"}}}' > ~/.qwen/settings.json && \
    echo 'OPENAI_API_KEY=dummy' > ~/.qwen/.env

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash

# Configure Claude Code for vLLM endpoint
# Set up environment variables in both bashrc and zshrc
RUN echo 'export ANTHROPIC_BASE_URL="'"$ENDPOINT"'"' >> ~/.bashrc && \
    echo 'export ANTHROPIC_API_KEY="'"$API_KEY"'"' >> ~/.bashrc && \
    echo 'export ANTHROPIC_AUTH_TOKEN="'"$API_KEY"'"' >> ~/.bashrc && \
    echo 'export ANTHROPIC_DEFAULT_OPUS_MODEL="'"$MODEL"'"' >> ~/.bashrc && \
    echo 'export ANTHROPIC_DEFAULT_SONNET_MODEL="'"$MODEL"'"' >> ~/.bashrc && \
    echo 'export ANTHROPIC_DEFAULT_HAIKU_MODEL="'"$MODEL"'"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    echo 'export TERM=xterm-256color' >> ~/.bashrc && \
    echo 'export ANTHROPIC_BASE_URL="'"$ENDPOINT"'"' >> ~/.zshrc && \
    echo 'export ANTHROPIC_API_KEY="'"$API_KEY"'"' >> ~/.zshrc && \
    echo 'export ANTHROPIC_AUTH_TOKEN="'"$API_KEY"'"' >> ~/.zshrc && \
    echo 'export ANTHROPIC_DEFAULT_OPUS_MODEL="'"$MODEL"'"' >> ~/.zshrc && \
    echo 'export ANTHROPIC_DEFAULT_SONNET_MODEL="'"$MODEL"'"' >> ~/.zshrc && \
    echo 'export ANTHROPIC_DEFAULT_HAIKU_MODEL="'"$MODEL"'"' >> ~/.zshrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && \
    echo 'export TERM=xterm-256color' >> ~/.zshrc

# Create Claude Code settings.json with vLLM config
RUN python3 - "$HOME/.claude.json" "$ENDPOINT" "$MODEL" "$API_KEY" << 'PYEOF'
import json
import sys

try:
    config_path = sys.argv[1]
    endpoint = sys.argv[2]
    model = sys.argv[3]
    api_key = sys.argv[4]

    config = {
        "modelProviders": {
            "anthropic": {
                "baseUrl": endpoint
            }
        },
        "model": model,
        "hasCompletedOnboarding": True,
        "env": {
            "ANTHROPIC_API_KEY": api_key
        }
    }

    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
        f.write("\n")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
PYEOF

# Drop into bash shell by default
CMD ["bash"]
