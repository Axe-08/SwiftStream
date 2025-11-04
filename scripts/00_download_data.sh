#!/bin/bash
# scripts/00_download_data.sh

# This script downloads LibriSpeech subsets to a target directory.
# It supports downloading a 'debug' subset or the 'full' dataset.

set -e # Exit immediately if a command fails

# --- Configuration ---
URL_DEV_CLEAN="https://www.openslr.org/resources/12/dev-clean.tar.gz"
URL_TEST_CLEAN="https://www.openslr.org/resources/12/test-clean.tar.gz"
URL_TRAIN_100="https://www.openslr.org/resources/12/train-clean-100.tar.gz"
URL_TRAIN_360="https://www.openslr.org/resources/12/train-clean-360.tar.gz"
URL_TRAIN_500="https://www.openslr.org/resources/12/train-other-500.tar.gz"

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
    echo "Usage: $0 --subset [debug|full|full-960] --output_dir /path/to/gdrive/raw"
    exit 1
fi

# We will be running this inside the container, which has rclone.
# We assume the OUTPUT_DIR is a path to a mounted G-Drive.
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

elif [ "$SUBSET" = "full-960" ]; then
    echo "Downloading full LibriSpeech 960h dataset..."
    for url in $URL_DEV_CLEAN $URL_TEST_CLEAN $URL_TRAIN_100 $URL_TRAIN_360 $URL_TRAIN_500; do
        filename=$(basename "$url")
        if [ ! -f "$filename" ]; then
            echo "Downloading $filename..."
            wget "$url"
        else
            echo "$filename already exists, skipping."
        fi
    done
else
    echo "Error: Unknown subset '$SUBSET'. Use 'debug' or 'full-960'."
    exit 1
fi

echo "--- Download complete. ---"