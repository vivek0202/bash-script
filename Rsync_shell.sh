#!/bin/bash

# === CONFIGURABLE VARIABLES ===
SRC_SERVER="source_user@source_host"
DST_SERVER="dest_user@dest_host"
SRC_BASE_DIR="/dataserver"
DST_BASE_DIR="/dataserver"
EXCLUDE_LIST=(
  "$SRC_BASE_DIR/lqextracts/asp/script/ssp_script.sh"
  "$SRC_BASE_DIR/ftp/per/per.pl"
  "$SRC_BASE_DIR/ftp/transactionLogs"
  "$SRC_BASE_DIR/iview/iview_main/etc/config/jdbc.properties"
)

LOG_FILE="/tmp/rsync_job_$(date +%F_%H-%M-%S).log"
EMAIL_TO="your_email@example.com"
SUBJECT="Rsync Job Status - $(hostname)"

# === FUNCTION TO BUILD EXCLUDE FLAGS ===
build_exclude_flags() {
  local flags=""
  for path in "${EXCLUDE_LIST[@]}"; do
    flags+="--exclude='$path' "
  done
  echo "$flags"
}

# === BEGIN SCRIPT ===
echo "Rsync job started at $(date)" > "$LOG_FILE"

EXCLUDE_FLAGS=$(build_exclude_flags)

# 1. Run rsync for base directory with all excludes
echo -e "\nRunning main rsync job with excludes..." >> "$LOG_FILE"
eval rsync -av $EXCLUDE_FLAGS "$SRC_SERVER:$SRC_BASE_DIR/" "$DST_SERVER:$DST_BASE_DIR/" >> "$LOG_FILE" 2>&1

# 2. Optional: Add specific subdirectory rsync (SOAC example)
SOAC_DIR="$SRC_BASE_DIR/soac"
echo -e "\nRunning SOAC rsync..." >> "$LOG_FILE"
rsync -av "$SRC_SERVER:$SOAC_DIR" "$DST_SERVER:$DST_BASE_DIR/" >> "$LOG_FILE" 2>&1

echo -e "\nRsync job completed at $(date)" >> "$LOG_FILE"

# === SEND EMAIL ===
mail -s "$SUBJECT" "$EMAIL_TO" < "$LOG_FILE"
