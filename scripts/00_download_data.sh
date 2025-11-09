#!/bin/bash
# scripts/00_download_data.sh (v4 - Extraction Path Fix)
#
# BUG FIX: The .tar.gz files from OpenSLR already contain
# the 'LibriSpeech/' directory. This version extracts
# directly in the OUTPUT_DIR.

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

echo "--- Starting Manual Download & Extraction ---"
echo "Mode: $SUBSET"
echo "Target: $OUTPUT_DIR"

if [ "$SUBSET" = "debug" ]; then
    echo "Downloading LibriSpeech 'dev-clean'..."
    [ ! -f "dev-clean.tar.gz" ] && wget -q --show-progress "$URL_DEV_CLEAN"
    
    echo "Downloading LibriSpeech 'test-clean'..."
    [ ! -f "test-clean.tar.gz" ] && wget -q --show-progress "$URL_TEST_CLEAN"
    
    echo "--- Extraction ---"
    # THE FIX: Extract directly here. The tarballs contain 'LibriSpeech/...'
    
    echo "Extracting dev-clean..."
    tar -xzf dev-clean.tar.gz
    
    echo "Extracting test-clean..."
    tar -xzf test-clean.tar.gz
    
    echo "Cleaning up tarballs..."
    rm dev-clean.tar.gz test-clean.tar.gz

elif [ "$SUBSET" = "full-960" ]; then
    echo "Downloading full LibriSpeech 960h set..."
    # ... This section would be expanded to download all parts ...
fi

echo "--- Download and extraction complete. ---"