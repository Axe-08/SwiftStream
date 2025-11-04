#!/bin/bash
# scripts/01_preprocess_data.sh (v2.1 - Fix espnet_preparer path)

set -e # Exit immediately if a command fails

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

echo "--- Starting ESPnet Data Prep (Pythonic Way) ---"
echo "Raw Data (Input): $INPUT_DIR"
echo "Processed Data (Output): $OUTPUT_DIR"

if [ "$SUBSET" = "debug" ]; then
    echo "Running in DEBUG mode on dev-clean only."
    # This will find dev-clean.tar.gz in INPUT_DIR and create
    # OUTPUT_DIR/dev-clean/wav.scp, text, etc.
    python -m espnet_preparer \
        --dataset librispeech \
        --datadir "$INPUT_DIR" \
        --outdir "$OUTPUT_DIR" \
        --subset dev-clean

elif [ "$SUBSET" = "full-960" ]; then
    echo "Running in FULL-960 mode."
    # This will find all the .tar.gz files and process them.
    python -m espnet_preparer \
        --dataset librispeech \
        --datadir "$INPUT_DIR" \
        --outdir "$OUTPUT_DIR" \
        --subset train-clean-100 train-clean-360 train-other-500 test-clean dev-clean
else
    echo "Error: Unknown subset '$SUBSET'. Use 'debug' or 'full-960'."
    exit 1
fi

echo "---------------------------------"
echo "Data processing complete."
echo "Check $OUTPUT_DIR for your processed data."
echo "---------------------------------"