#!/bin/bash
# scripts/01_preprocess_data.sh (v11 - Fix argument quoting)

set -e

ESPnet_RECIPE_DIR="/opt/espnet/egs2/librispeech/asr1"

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
    exit 1
fi

echo "--- Starting ESPnet Data Prep (Stage 2 ONLY) ---"
echo "Using Recipe: $ESPnet_RECIPE_DIR"
echo "Raw Data (Input): $INPUT_DIR"
echo "Processed Data (Output): $OUTPUT_DIR"

cd "$ESPnet_RECIPE_DIR"

if [ "$SUBSET" = "debug" ]; then
    train_set="dev_clean"
    valid_set="test_clean"
    test_sets="test_clean"
elif [ "$SUBSET" = "full-960" ]; then
    train_set="train_960"
    valid_set="dev_clean"
    test_sets="test_clean test_other dev_clean dev_other"
fi

# --- THIS IS THE FIX ---
# We run ONLY Stage 2 (Data Prep).
# We pass --local_data_opts with a single, QUOTED string
# to tell the sub-script where our pre-downloaded data is.
./asr.sh \
    --stage 2 \
    --stop_stage 2 \
    --ngpu 0 \
    --nj 32 \
    --train_set "$train_set" \
    --valid_set "$valid_set" \
    --test_sets "$test_sets" \
    --dumpdir "$OUTPUT_DIR" \
    --local_data_opts "--datadir $INPUT_DIR"

echo "---------------------------------"
echo "Data processing complete."
# The script will create subdirs inside $OUTPUT_DIR, e.g., $OUTPUT_DIR/dev_clean
echo "Processed data is in: $OUTPUT_DIR"
echo "---------------------------------"