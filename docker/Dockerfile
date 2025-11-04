# --- Base Image ---
# We use an official NVIDIA PyTorch image from NGC (NVIDIA GPU Cloud).
# The 24.04 tag is from April 2024, built with CUDA 12.4 components.
# This is fully compatible with your DGX host driver (550.144.03) and V100 GPUs.
FROM nvcr.io/nvidia/pytorch:24.04-py3

# --- Environment Variables ---
# Set the working directory for the project.
WORKDIR /workspace/swiftstream-asr

# Set DEBIAN_FRONTEND to noninteractive to prevent apt-get from hanging.
ENV DEBIAN_FRONTEND=noninteractive

# --- System-Level Dependencies ---
# We install all necessary system libraries.
# - rclone: Critical for accessing the 1TB G-Drive (per C-4, EIF-2).
#           This solves the "no sudo on host" problem.
# - ffmpeg, sox, libsndfile1: Required by ESPnet and torchaudio for audio
#                            processing, loading, and feature extraction.
# - git: Required for pip to install dependencies directly from Git repos.
RUN apt-get update && apt-get install -y \
    rclone \
    ffmpeg \
    sox \
    libsndfile1 \
    git \
    build-essential \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- Python Dependencies ---
# First, copy *only* the requirements file. This allows Docker to cache
# this layer. The long install step will only re-run if requirements.txt changes.
COPY requirements.txt .

# Install all Python packages from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# --- Copy Project Code ---
# Now, copy the entire project (src, scripts, conf, etc.) into the workspace.
# The .dockerignore file (which should be similar to .gitignore) will
# prevent .venv, local_test_data, etc., from being copied.
COPY . .

# --- Entrypoint & Default Command ---
# Copy the entrypoint script (which you can use for setup logic)
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command to "bash" to make the container interactive
# when you run it (docker run -it swiftstream).
CMD ["bash"]
