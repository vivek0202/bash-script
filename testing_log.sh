#!/bin/bash

LOG_DIR="/provco/OneNetwork/scripts/logs"
SERVICES_FILE="/provco/OneNetwork/scripts/Services"
DATE_YYYYMMDD=$(date +%Y%m%d)
DATE_DASHED=$(date +%Y-%m-%d)

while read -r SERVICE; do
  [[ -z "$SERVICE" ]] && continue

  echo "🔍 Checking logs for service: $SERVICE"

  MATCHED_LOGS=$(find "$LOG_DIR" -type f \( \
    -name "${SERVICE}.log" -o \
    -name "${SERVICE}_${DATE_DASHED}*.log" -o \
    -name "${SERVICE}.${DATE_YYYYMMDD}.out" \))

  for LOG in $MATCHED_LOGS; do
    echo "✅ Found log file: $LOG"
  done

done < "$SERVICES_FILE"
