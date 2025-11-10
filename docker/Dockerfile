# --- Base Image ---
FROM nvcr.io/nvidia/pytorch:24.04-py3

# --- Environment Variables ---
WORKDIR /workspace/swiftstream-asr
ENV DEBIAN_FRONTEND=noninteractive

# --- System-Level Dependencies ---
# (Added libsndfile-dev and bc for ESPnet scripts)
RUN apt-get update && apt-get install -y \
    rclone \
    ffmpeg \
    sox \
    libsndfile1 \
    libsndfile1-dev \
    flac \
    git \
    build-essential \
    cmake \
    bc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# --- Python Dependencies ---
# (This step is unchanged)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip uninstall -y torchvision
# --- NEW: Clone ESPnet for Recipes ---
# This is the step we were missing.
# We clone the full repo to /opt/espnet to get the egs2/ scripts.
RUN git clone https://github.com/espnet/espnet /opt/espnet

# --- Copy Project Code ---
COPY . .

# --- Entrypoint & Default Command ---
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]