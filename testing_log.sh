#!/bin/bash

LOG_DIR="/provco/OneNetwork/scripts/logs"
SERVICES_FILE="/provco/OneNetwork/scripts/Services"
DATE_YYYYMMDD=$(date +%Y%m%d)
DATE_DASHED=$(date +%Y-%m-%d)

# Define error patterns to test
ERROR_PATTERNS=(
  "java.io.IOException: Connection reset by peer"
  "shutdown.jar"
  "Broken pipe"
  "TimeoutException"
)

echo "📋 Starting dry run to check for error patterns in log files..."

while read -r SERVICE; do
  [[ -z "$SERVICE" ]] && continue

  echo -e "\n🔍 Checking service: $SERVICE"

  MATCHED_LOGS=$(find "$LOG_DIR" -type f \( \
    -name "${SERVICE}.log" -o \
    -name "${SERVICE}_${DATE_DASHED}*.log" -o \
    -name "${SERVICE}.${DATE_YYYYMMDD}.out" \))

  for LOG in $MATCHED_LOGS; do
    for PATTERN in "${ERROR_PATTERNS[@]}"; do
      if grep -q "$PATTERN" "$LOG"; then
        echo "⚠️  MATCH FOUND: '$PATTERN' in log: $LOG"
      fi
    done
  done

done < "$SERVICES_FILE"
