#!/bin/bash

# This script downloads LibriSpeech subsets to a target directory.
# It supports downloading a 'debug' subset or the 'full' dataset.

set -e # Exit immediately if a command fails

# --- Configuration ---
# These URLs are for the main LibriSpeech datasets
URL_DEV_CLEAN="https://www.openslr.org/resources/12/dev-clean.tar.gz"
URL_TEST_CLEAN="https://www.openslr.org/resources/12/test-clean.tar.gz"
URL_TRAIN_100="https://www.openslr.org/resources/12/train-clean-100.tar.gz"
# Add other URLs (train-360, train-500, etc.) here if needed.

# --- Argument Parsing ---
SUBSET="debug" # Default to debug
OUTPUT_DIR=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --subset) SUBSET="$2"; shift ;;
        --output_dir) OUTPUT_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$OUTPUT_DIR" ]; then
    echo "Error: --output_dir is required."
    echo "Usage: $0 --subset [debug|full] --output_dir /path/to/gdrive/raw"
    exit 1
fi

# Create the output directory if it doesn't exist
# We assume /path/to/gdrive is mounted or accessible.
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo "--- Starting Download ---"
echo "Mode: $SUBSET"
echo "Target: $OUTPUT_DIR"

if [ "$SUBSET" = "debug" ]; then
    echo "Downloading LibriSpeech 'dev-clean' for debugging..."
    if [ ! -f "dev-clean.tar.gz" ]; then
        wget "$URL_DEV_CLEAN"
    else
        echo "dev-clean.tar.gz already exists, skipping."
    fi
    echo "Debug dataset download complete."

elif [ "$SUBSET" = "full" ]; then
    echo "Downloading full LibriSpeech dataset..."
    
    echo "Downloading dev-clean..."
    [ ! -f "dev-clean.tar.gz" ] && wget "$URL_DEV_CLEAN"
    
    echo "Downloading test-clean..."
    [ ! -f "test-clean.tar.gz" ] && wget "$URL_TEST_CLEAN"
    
    echo "Downloading train-clean-100..."
    [ ! -f "train-clean-100.tar.gz" ] && wget "$URL_TRAIN_100"
    
    # Add other 'wget' commands for train-360 etc. here
    
    echo "Full dataset download complete."
else
    echo "Error: Unknown subset '$SUBSET'. Use 'debug' or 'full'."
    exit 1
fi

echo "-------------------------"