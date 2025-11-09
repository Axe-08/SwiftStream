#!/bin/bash
# scripts/00_download_data.sh (v2 - Manual Download)

set -e

# --- Configuration ---
URL_DEV_CLEAN="https://www.openslr.org/resources/12/dev-clean.tar.gz"
URL_TEST_CLEAN="https://www.openslr.org/resources/12/test-clean.tar.gz"

# --- Argument Parsing ---
SUBSET="debug"
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
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo "--- Starting Manual Download ---"
echo "Mode: $SUBSET"
echo "Target: $OUTPUT_DIR"

if [ "$SUBSET" = "debug" ]; then
    echo "Downloading LibriSpeech 'dev-clean'..."
    [ ! -f "dev-clean.tar.gz" ] && wget "$URL_DEV_CLEAN"
    
    echo "Downloading LibriSpeech 'test-clean'..."
    [ ! -f "test-clean.tar.gz" ] && wget "$URL_TEST_CLEAN"

elif [ "$SUBSET" = "full-960" ]; then
    echo "Downloading full LibriSpeech 960h set..."
    wget -c "$URL_DEV_CLEAN"
    wget -c "$URL_TEST_CLEAN"
    # ... add train-100, 360, 500 etc. ...
fi

echo "--- Download complete. ---"