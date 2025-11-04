#!/bin/bash
# scripts/01_preprocess_data.sh

# This script runs the ESPnet data processing (Stages 1 & 2)
# on the data downloaded by 00_download_data.sh.

set -e

# --- Configuration ---
# This is a GUESS for the path inside the Docker container.
# We will find the real path in Step 3.
ESPnet_RECIPE_DIR="/usr/local/lib/python3.10/site-packages/espnet/egs2/librispeech/asr1"

# --- Argument Parsing ---
SUBSET="debug"
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
    echo "Usage: $0 --subset [debug|full-960] --input_dir /path/to/gdrive/raw --output_dir /path/to/gdrive/processed"
    exit 1
fi

if [ ! -d "$ESPnet_RECIPE_DIR" ]; then
    echo "Error: ESPnet LibriSpeech recipe not found at $ESPnet_RECIPE_DIR"
    echo "This script must be run inside the Docker container."
    echo "Please find the correct path to 'espnet/egs2/librispeech/asr1' and update this script."
    exit 1
fi

echo "--- Starting ESPnet Data Prep ---"
echo "Using Recipe: $ESPnet_RECIPE_DIR"
echo "Raw Data (Input): $INPUT_DIR"
echo "Processed Data (Output): $OUTPUT_DIR"

# Go to the recipe directory
cd "$ESPnet_RECIPE_DIR"

# Set the datasets to process based on the subset
if [ "$SUBSET" = "debug" ]; then
    echo "Running in DEBUG mode on dev-clean only."
    train_set="dev_clean" # Use dev-set as dummy train set
    dev_set="dev_clean"
    test_sets="dev_clean"
elif [ "$SUBSET" = "full-960" ]; then
    echo "Running in FULL-960 mode."
    train_set="train_960"
    dev_set="dev_clean"
    test_sets="test_clean"
fi

# Run ESPnet asr.sh
# --stage 1: Data Download (in this case, just unpacks)
# --stop_stage 2: Data preparation (creates wav.scp, text, etc.)
# --librispeech_datadir: Where our script will look for the .tar.gz files
# --dumpdir: Where ESPnet will write the processed files
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