#!/bin/bash

# This script performs all setup tasks for User Story 1 of the SwiftStream project.

echo "--- Starting Project SwiftStream Setup ---"

# --- Task 1.1: Initialize Git ---
echo "1. Initializing Git repository..."
git init

# --- Task 1.1: Create .gitignore ---
echo "2. Creating .gitignore file..."
cat <<EOF > .gitignore
# Python cache & artifacts
__pycache__/
*.pyc
*.pyo

# Virtual Environment (per US1.1)
.venv/
venv/

# Local Mock Data (per US1.1)
local_test_data/

# Cloud-synced Data (Must not be committed)
# These will be on G-Drive, not in the repo.
raw_data/
processed_data/
checkpoints/

# OS / IDE specific
.DS_Store
.vscode/
.idea/

# Local logs
*.log
EOF

# --- Task 1.2: Create Directory Structure ---
echo "3. Creating project directory structure..."
mkdir -p docker
mkdir -p scripts/utils
mkdir -p src/swiftstream/models
mkdir -p src/swiftstream/server
mkdir -p conf
mkdir -p local_test_data

echo "4. Creating empty files..."
# Root
touch Makefile

# Docker
touch docker/Dockerfile
touch docker/entrypoint.sh

# Config
touch conf/fm_train_config.yaml

# Scripts
touch scripts/00_download_data.sh
touch scripts/01_preprocess_data.sh
touch scripts/02_run_b1_eval.py
touch scripts/03_run_b2_benchmark.py
touch scripts/04_run_fm_training.sh
touch scripts/utils/text_normalizer.py

# Python Source
touch src/swiftstream/__init__.py
touch src/swiftstream/config.py
touch src/swiftstream/models/__init__.py
touch src/swiftstream/models/streaming_whisper.py
touch src/swiftstream/models/conmamba_espnet.py
touch src/swiftstream/server/__init__.py
touch src/swiftstream/server/websocket_server.py

# --- Task 1.4: Define Dependencies ---
echo "5. Creating requirements.txt..."
cat <<EOF > requirements.txt
# Core ML
torch
transformers
huggingface_hub

# ASR Toolkit
espnet
# Note: You may need a specific version or branch for Mamba support

# Experiment Tracking
wandb

# Server
fastapi
uvicorn[standard]
python-socketio
EOF

echo "--- Project setup complete! ---"
echo ""
echo "Next steps (from your Sprint Plan):"
echo "1. Create your local vEnv: python -m venv .venv"
echo "2. Activate it: source .venv/bin/activate"
echo "3. Install dependencies: pip install -r requirements.txt (Task 1.5)"
echo "4. Start writing the Dockerfile! (Task 1.6)"
