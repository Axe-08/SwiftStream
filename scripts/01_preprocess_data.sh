#!/bin/bash
# scripts/01_preprocess_data.sh (v7 - Final debug logic)

# This script runs the ESPnet data processing (Stages 1 & 2)
# by calling the asr.sh recipe, which we cloned into /opt/espnet.

set -e

# This path is guaranteed to exist from our Dockerfile
ESPnet_RECIPE_DIR="/opt/espnet/egs2/librispeech/asr1"

# --- Argument Parsing ---
SUBSET="debug"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --subset) SUBSET="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "--- Starting ESPnet Data Prep (asr.sh) ---"
echo "Using Recipe: $ESPnet_RECIPE_DIR"
echo "Mode: $SUBSET"

# Go to the recipe directory
cd "$ESPnet_RECIPE_DIR"

# Set the datasets to process based on the subset
if [ "$SUBSET" = "debug" ]; then
    echo "Running in DEBUG mode."
    # FIX: Use dev_clean as train, test_clean as valid,
    # and an empty test_sets to satisfy script's safety checks.
    train_set="dev_clean"
    valid_set="test_clean"
    test_sets="" # We don't need to process a test set for this debug run

elif [ "$SUBSET" = "full-960" ]; then
    echo "Running in FULL-960 mode."
    train_set="train_960"
    valid_set="dev_clean"
    test_sets="test_clean test_other dev_clean dev_other"
fi

# Run ESPnet asr.sh
# --stage 1: Data Download (downloads to its *own* 'downloads/' dir)
# --stop_stage 2: Data preparation (creates wav.scp, text, etc.)
# The output will be in 'dump/raw/'
./asr.sh \
    --stage 1 \
    --stop_stage 2 \
    --ngpu 0 \
    --nj 32 \
    --train_set "$train_set" \
    --valid_set "$valid_set" \
    --test_sets "$test_sets"

echo "---------------------------------"
echo "Data processing complete."
echo "Processed data is in: $ESPnet_RECIPE_DIR/dump/raw/"
echo "---------------------------------"