#!/bin/bash

# Email variables
TO_EMAIL="your-email@example.com"
SUBJECT="Rsync Transfer Completed"
BODY="Rsync file transfers have completed successfully."

# Common variables
SRC_HOST="vzpipview@tdclpalrba002.verizon.com"
DST_HOST="vzpipview@tpalpalrba006.verizon.com"

# Directories to sync (source_path destination_path)
declare -A SYNC_PATHS=(
  ["/dataserver/lqextracts/"]="/dataserver/lqextracts/"
  ["/dataserver/ftp/"]="/dataserver/ftp/"
  ["/dataserver/soac/"]="/dataserver/soac/"
)

# Rsync command execution
for SRC_PATH in "${!SYNC_PATHS[@]}"; do
  DST_PATH=${SYNC_PATHS[$SRC_PATH]}

  echo "Syncing $SRC_PATH to $DST_PATH..."
  rsync -avz -e ssh "${SRC_HOST}:${SRC_PATH}" "${DST_HOST}:${DST_PATH}"

  if [ $? -ne 0 ]; then
    echo "Rsync failed for $SRC_PATH" | mail -s "Rsync Failed" "$TO_EMAIL"
    exit 1
  fi
done

# Send success email
echo "$BODY" | mail -s "$SUBJECT" "$TO_EMAIL"
