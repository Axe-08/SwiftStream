#!/bin/bash
#
# Sprint 2, Phase 2.1: Run B1 (Batch Whisper) Evaluation
#
# This script does the following:
# 1. Sets the test dataset (test_clean).
# 2. Copies the ESPnet data dir (wav.scp, etc.) from G-Drive to /tmp.
# 3. FIX: Creates a 'downloads' symlink in the CWD to point to the
#    raw audio data, fixing the relative paths in wav.scp.
# 4. Runs the B1 evaluation script on it using cuda:0.
# 5. Logs all results to W&B.

set -e

# --- Configuration ---
GDRIVE_DATA_PATH="gdrive:swiftstream_data/processed"
LOCAL_DATA_DIR="/tmp/sprint2_data"
TEST_SET="test_clean"
RAW_AUDIO_DIR="/tmp/data/raw" # This is where our raw audio lives from Sprint 1

# --- 1. Sync Data from G-Drive ---
echo "--- Syncing $TEST_SET from G-Drive to $LOCAL_DATA_DIR ---"
mkdir -p $LOCAL_DATA_DIR/$TEST_SET
rclone copy $GDRIVE_DATA_PATH/$TEST_SET $LOCAL_DATA_DIR/$TEST_SET

echo "Data sync complete."

# --- 2. THE FIX: Re-create the symlink ---
echo "--- Creating 'downloads' symlink in CWD ---"
# This makes the relative paths in wav.scp (e.g., "downloads/LibriSpeech/...")
# resolve correctly from the /workspace/swiftstream-asr/ directory.
ln -sf $RAW_AUDIO_DIR downloads

# --- 3. Run Evaluation ---
echo "--- Running B1 (Batch Whisper) Evaluation on cuda:0 ---"
# We're using the data from the /tmp directory for fast I/O
python scripts/02_run_b1_eval.py \
    --data_dir $LOCAL_DATA_DIR/$TEST_SET \
    --device cuda:0

echo "---"
echo "B1 evaluation complete. Check W&B for results."
echo "---"