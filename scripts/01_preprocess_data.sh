#!/bin/bash

# This script runs the ESPnet data processing (Stages 1 & 2)
# on the data downloaded by 00_download_data.sh.

set -e

# --- Configuration ---
# This is the standard path *inside* the official ESPnet Docker container.
# We will assume our Docker image has it in a similar location.
# If not, we'll find it and update this.
ESPENT_LIBRISPEECH_RECIPE="/opt/espnet/egs2/librispeech/asr1"

if [ ! -d "$ESPENT_LIBRISPEECH_RECIPE" ]; then
    echo "Error: ESPnet LibriSpeech recipe not found at $ESPENT_LIBRISPEECH_RECIPE"
    echo "This script must be run inside the Docker container."
    # We might need to find the real path later, e.g., using:
    # find / -name "librispeech" 2>/dev/null
    # For now, we'll assume a path. Let's try:
    ESPENT_LIBRISPEECH_RECIPE="/workspace/swiftstream-asr/espnet/egs2/librispeech/asr1"
    if [ ! -d "$ESPENT_LIBRISPEECH_RECIPE" ]; then
        echo "Error: Also not found at $ESPENT_LIBRISPEECH_RECIPE"
        echo "Please find the 'espnet/egs2/librispeech/asr1' dir and update this script."
        exit 1
    fi
fi

# --- Argument Parsing ---
SUBSET="debug" # Default to debug
INPUT_DIR=""   # This is the /raw dir where .tar.gz files are
OUTPUT_DIR=""  # This is the /processed dir where Kaldi files will go

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --subset) SUBSET="$2"; shift ;;
        --input_dir) INPUT_DIR="$2"; shift ;;
        --output_dir) OUTPUT_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Error: --input_dir and --output_dir are required."
    echo "Usage: $0 --subset [debug|full] --input_dir /path/to/gdrive/raw --output_dir /path/to/gdrive/processed"
    exit 1
fi

echo "--- Starting ESPnet Data Prep ---"
echo "Recipe: $ESPENT_LIBRISPEECH_RECIPE"
echo "Raw Data (Input): $INPUT_DIR"
echo "Processed Data (Output): $OUTPUT_DIR"

# This is the magic. We run the official ESPnet script
# and tell it to ONLY run stages 1 (unpack) and 2 (format).
# We also override its 'datadir' and 'dumpdir' to point to our G-Drive.
cd "$ESPENT_LIBRISPEECH_RECIPE"

# Set the datasets to process based on the subset
train_set="train_clean_100"
dev_set="dev_clean"
test_sets="test_clean"

if [ "$SUBSET" = "debug" ]; then
    echo "Running in DEBUG mode on dev-clean only."
    train_set="dev_clean" # Use dev-set as dummy train set
    dev_set="dev_clean"
    test_sets="dev_clean"
elif [ "$SUBSET" = "full" ]; then
    echo "Running in FULL mode."
    # These are the default sets, but we set them for clarity
    train_set="train_clean_100" # Or train_960
    dev_set="dev_clean"
    test_sets="test_clean" # Add test_other etc.
fi

# Run ESPnet asr.sh
# --stage 1: Data Download (in this case, just unpacks)
# --stop_stage 2: Data preparation (creates wav.scp, text, etc.)
# librispeech_datadir: Where our script will look for the .tar.gz files
# dumpdir: Where ESPnet will write the processed files
./asr.sh \
    --stage 1 \
    --stop_stage 2 \
    --ngpu 0 \
    --nj 32 \
    --train_set "$train_set" \
    --valid_set "$dev_set" \
    --test_sets "$test_sets" \
    --librispeech_datadir "$INPUT_DIR" \
    --dumpdir "$OUTPUT_DIR"

echo "---------------------------------"
echo "Data processing complete."
echo "Check $OUTPUT_DIR for your processed data."
echo "---------------------------------"