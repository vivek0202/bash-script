#!/bin/bash

# Email variables
TO_EMAIL="your-email@example.com"
SUBJECT_SUCCESS="Rsync Transfer Completed"
SUBJECT_FAILURE="Rsync Transfer Failed"
LOG_FILE="/tmp/rsync_transfer.log"
> "$LOG_FILE"  # Clear previous log

# Common variables
SRC_HOST="vzpipview@tdclpalrba002.verizon.com"
DST_HOST="vzpipview@tpalpalrba006.verizon.com"

# Directories to sync (source_path destination_path)
declare -A SYNC_PATHS=(
  ["/dataserver/lqextracts/"]="/dataserver/lqextracts/"
  ["/dataserver/ftp/"]="/dataserver/ftp/"
  ["/dataserver/iview/"]="/dataserver/iview/"
)

# Rsync command execution
echo "[$(date)] Starting rsync transfer job" >> "$LOG_FILE"

for SRC_PATH in "${!SYNC_PATHS[@]}"; do
  DST_PATH=${SYNC_PATHS[$SRC_PATH]}
  echo "[$(date)] Syncing $SRC_PATH to $DST_PATH..." >> "$LOG_FILE"

  # Prepare exclusion patterns based on current source path
  EXCLUDES=""
  if [[ "$SRC_PATH" == "/dataserver/lqextracts/" ]]; then
    EXCLUDES+="--exclude='ssp/script/ssp_script.sh' "
  elif [[ "$SRC_PATH" == "/dataserver/ftp/" ]]; then
    EXCLUDES+="--exclude='per/per.pl' "
  elif [[ "$SRC_PATH" == "/dataserver/iview/" ]]; then
    EXCLUDES+="--exclude='view_main/etc/config/jdbc.properties' "
  fi

  eval rsync -avz -e ssh $EXCLUDES "${SRC_HOST}:${SRC_PATH}" "${DST_HOST}:${DST_PATH}" >> "$LOG_FILE" 2>&1

  if [ $? -ne 0 ]; then
    echo "[$(date)] ❌ Rsync failed for $SRC_PATH" >> "$LOG_FILE"
    tail -n 30 "$LOG_FILE" | mail -s "$SUBJECT_FAILURE" "$TO_EMAIL"
    exit 1
  fi

  echo "[$(date)] ✅ Rsync completed for $SRC_PATH" >> "$LOG_FILE"
done

echo "[$(date)] ✅ All rsync transfers completed successfully" >> "$LOG_FILE"

# Send success email with last lines of log
tail -n 30 "$LOG_FILE" | mail -s "$SUBJECT_SUCCESS" "$TO_EMAIL"
