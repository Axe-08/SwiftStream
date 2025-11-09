#!/bin/bash
# scripts/01_preprocess_data.sh (v13 - The "Manual" Fix)
#
# This script is now robust. It implements the "symlink"
# method we discovered during debugging. It no longer calls
# asr.sh, but instead directly calls local/data.sh
# after creating the 'downloads' symlink.

set -e

ESPnet_RECIPE_DIR="/opt/espnet/egs2/librispeech/asr1"

# --- Argument Parsing ---
# We only need the --input_dir (where /raw is)
INPUT_DIR=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input_dir) INPUT_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$INPUT_DIR" ]; then
    echo "Error: --input_dir is required (e.g., /tmp/data/raw)."
    exit 1
fi

echo "--- Starting ESPnet Data Prep (Symlink Method) ---"
echo "Using Recipe: $ESPnet_RECIPE_DIR"
echo "Raw Data (Input): $INPUT_DIR"

cd "$ESPnet_RECIPE_DIR"

# Clean up old links just in case
rm -f downloads
rm -f LibriSpeech

echo "Creating 'downloads' symlink..."
ln -s "$INPUT_DIR" downloads

echo "Verifying link..."
ls -l downloads
ls -l downloads/LibriSpeech

echo "Running data preparation..."
# This is the command that does all the work.
# It will find 'flac' (thanks to the Dockerfile fix)
# and process all data inside the 'downloads/LibriSpeech' dir.
./local/data.sh

echo "---------------------------------"
echo "Data processing complete."
echo "Processed data is in: $ESPnet_RECIPE_DIR/data/"
echo "---------------------------------"

# Go back to the original directory
cd -