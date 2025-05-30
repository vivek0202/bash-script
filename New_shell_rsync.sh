#!/bin/bash

# ====== Input arguments ======
SRC_SERVER="$1"
DST_SERVER="$2"
EMAIL_TO="$3"

# ====== Validate inputs ======
if [[ -z "$SRC_SERVER" || -z "$DST_SERVER" || -z "$EMAIL_TO" ]]; then
  echo "Usage: $0 <source_user@source_host> <dest_user@dest_host> <email>"
  exit 1
fi

# ====== Variables ======
TIMESTAMP=$(date +%F_%H-%M-%S)
LOG_FILE="/tmp/rsync_log_${TIMESTAMP}.log"
SUBJECT_SUCCESS="✅ Rsync Job Succeeded - $(hostname)"
SUBJECT_FAIL="❌ Rsync Job Failed - $(hostname)"

echo "Rsync job started at $(date)" > "$LOG_FILE"

# ====== Run rsync jobs ======

# 1. Rsync with exclude ssp_script.sh
echo -e "\n[1] Syncing ASP directory (excluding ssp_script.sh)..." >> "$LOG_FILE"
rsync -av --exclude='/dataserver/lqextracts/asp/script/ssp_script.sh' \
  "$SRC_SERVER:/dataserver/" "$DST_SERVER:/dataserver/" >> "$LOG_FILE" 2>&1

# 2. Rsync FTP with two excludes
echo -e "\n[2] Syncing FTP directory (excluding per.pl, transactionLogs)..." >> "$LOG_FILE"
rsync -av --exclude='/dataserver/ftp/per/per.pl' \
          --exclude='/dataserver/ftp/transactionLogs' \
  "$SRC_SERVER:/dataserver/ftp" "$DST_SERVER:/dataserver/" >> "$LOG_FILE" 2>&1

# 3. Rsync SOAC directory
echo -e "\n[3] Syncing SOAC directory..." >> "$LOG_FILE"
rsync -av "$SRC_SERVER:/dataserver/soac" "$DST_SERVER:/dataserver/" >> "$LOG_FILE" 2>&1

# ====== Final status check ======
if [[ $? -eq 0 ]]; then
    echo -e "\nAll rsync tasks completed successfully at $(date)." >> "$LOG_FILE"
    mail -s "$SUBJECT_SUCCESS" "$EMAIL_TO" < "$LOG_FILE"
else
    echo -e "\nRsync encountered errors at $(date)." >> "$LOG_FILE"
    mail -s "$SUBJECT_FAIL" "$EMAIL_TO" < "$LOG_FILE"
fi
