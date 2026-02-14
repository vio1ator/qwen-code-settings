#!/bin/bash
# Setup script for Qwen Code CLI
# This script installs Qwen Code and configures it to use a custom vLLM endpoint

set -e

# Configuration variables (modify these as needed)
ENDPOINT="${ENDPOINT:-http://100.113.150.20:8000}"
MODEL="${MODEL:-Qwen/Qwen3-Coder-Next-FP8}"
API_KEY="${API_KEY:-dummy}"

echo "=== Qwen Code Setup Script ==="
echo "Endpoint: $ENDPOINT"
echo "Model: $MODEL"
echo ""

# Install Qwen Code CLI using official installation script
echo "Installing Qwen Code CLI..."
curl -fsSL https://qwen-code-assets.oss-cn-hangzhou.aliyuncs.com/installation/install-qwen.sh | bash
echo "✓ Qwen Code CLI installed successfully"
echo ""

# Create .qwen directory
echo "Creating configuration directory..."
QWEN_DIR="$HOME/.qwen"
mkdir -p "$QWEN_DIR"
echo "✓ Directory created: $QWEN_DIR"
echo ""

# Create settings.json
echo "Creating settings.json..."
cat > "$QWEN_DIR/settings.json" << EOF
{
  "modelProviders": {
    "openai": [
      {
        "id": "$MODEL",
        "name": "$MODEL",
        "envKey": "OPENAI_API_KEY",
        "baseUrl": "$ENDPOINT/v1",
        "authType": "openai",
        "generationConfig": {
          "contextWindowSize": 262144
        }
      }
    ]
  },
  "model": {
    "name": "$MODEL"
  },
  "security": {
    "auth": {
      "selectedType": "openai"
    }
  },
  "$version": 3,
  "mcpServers": {
    "exa": {
      "httpUrl": "https://mcp.exa.ai/mcp"
    }
  },
  "tools": {
    "sandbox": {
      "image": "qwen-code"
    }
  }
}
EOF
echo "✓ settings.json created"
echo ""

# Create .env file
echo "Creating .env file..."
echo "OPENAI_API_KEY=$API_KEY" > "$QWEN_DIR/.env"
echo "✓ .env file created"
echo ""

echo "=== Setup Complete ==="
echo ""
echo "You can now run 'qwen code' to start using Qwen Code CLI."
echo ""
