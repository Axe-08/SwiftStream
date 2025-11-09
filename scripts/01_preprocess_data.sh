#!/bin/bash
# scripts/01_preprocess_data.sh (v12 - THE REAL FIX)
#
# BUG 1 FIX: Changed --stage 2 and --stop_stage 2 to --stage 1 and --stop_stage 1.
#            We need to run Data Prep (Stage 1), not Speed Perturbation (Stage 2).
#
# BUG 2 FIX: Ensured --local_data_opts has its value as a *single quoted string*.
#            The log showed the quotes were missing in the executed version.

set -e

ESPnet_RECIPE_DIR="/opt/espnet/egs2/librispeech/asr1"

# --- Argument Parsing ---
SUBSET="debug"
INPUT_DIR=""   # This is the /raw dir where LibriSpeech/ is
OUTPUT_DIR="" # This is the /processed dir (used by asr.sh)

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

echo "--- Starting ESPnet Data Prep (Stage 1) ---"
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

# --- THE FIX (Stage 1 and Quoting) ---
# We run ONLY Stage 1 (Data Prep).
# We pass --local_data_opts with a single, QUOTED string.
./asr.sh \
    --stage 1 \
    --stop_stage 1 \
    --ngpu 0 \
    --nj 32 \
    --train_set "$train_set" \
    --valid_set "$valid_set" \
    --test_sets "$test_sets" \
    --dumpdir "$OUTPUT_DIR" \
    --local_data_opts "--datadir $INPUT_DIR"

echo "---------------------------------"
echo "Data processing complete."
# Stage 1 will create data in: $ESPnet_RECIPE_DIR/data/
echo "Processed data is in: $ESPnet_RECIPE_DIR/data/"
echo "---------------------------------"