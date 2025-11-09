#!/bin/bash
#
# Sprint 2, Phase 2.1: Run B1 (Batch Whisper) Evaluation
#
# This script does the following:
# 1. Sets the test dataset (test_clean).
# 2. Copies it from G-Drive to a fast /tmp directory.
# 3. Runs the B1 evaluation script on it using cuda:0.
# 4. Logs all results to W&B.

set -e

# --- Configuration ---
GDRIVE_DATA_PATH="gdrive:swiftstream_data/processed"
LOCAL_DATA_DIR="/tmp/sprint2_data"
TEST_SET="test_clean"

# --- 1. Sync Data from G-Drive ---
echo "--- Syncing $TEST_SET from G-Drive to $LOCAL_DATA_DIR ---"
mkdir -p $LOCAL_DATA_DIR/$TEST_SET
rclone copy $GDRIVE_DATA_PATH/$TEST_SET $LOCAL_DATA_DIR/$TEST_SET

echo "Data sync complete."

# --- 2. Run Evaluation ---
echo "--- Running B1 (Batch Whisper) Evaluation on cuda:0 ---"
# We're using the data from the /tmp directory for fast I/O
python scripts/02_run_b1_eval.py \
    --data_dir $LOCAL_DATA_DIR/$TEST_SET \
    --device cuda:0

echo "---"
echo "B1 evaluation complete. Check W&B for results."
echo "---"