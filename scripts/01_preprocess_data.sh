#!/bin/bash
# scripts/01_preprocess_data.sh (v3 - Correct Path)

# This script runs the ESPnet data processing (Stages 1 & 2)
# by calling the asr.sh recipe, which we cloned into /opt/espnet.

set -e

# --- Configuration ---
# This path is now GUARANTEED to exist because of our new Dockerfile
ESPnet_RECIPE_DIR="/opt/espnet/egs2/librispeech/asr1"

if [ ! -d "$ESPnet_RECIPE_DIR" ]; then
    echo "CRITICAL Error: ESPnet recipe not found at $ESPnet_RECIPE_DIR"
    exit 1
fi

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
    echo "Usage: $0 --subset [debug|full-960] --input_dir /tmp/data/raw --output_dir /tmp/data/processed"
    exit 1
fi

echo "--- Starting ESPnet Data Prep (asr.sh) ---"
echo "Using Recipe: $ESPnet_RECIPE_DIR"
echo "Raw Data (Input): $INPUT_DIR"
echo "Processed Data (Output): $OUTPUT_DIR"

# Go to the recipe directory
cd "$ESPnet_RECIPE_DIR"

# Set the datasets to process based on the subset
if [ "$SUBSET" = "debug" ]; then
    echo "Running in DEBUG mode on dev-clean only."
    # We use dev_clean as a dummy training set for a fast run
    train_set="dev_clean"
    dev_set="dev_clean"
    test_sets="dev_clean"

elif [ "$SUBSET" = "full-960" ]; then
    echo "Running in FULL-960 mode."
    train_set="train_960"
    dev_set="dev_clean"
    test_sets="test_clean test_other dev_other"
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