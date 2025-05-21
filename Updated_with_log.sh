#!/bin/bash

# Config
LOG_DIR="/provco/OneNetwork/scripts/log"
SERVICES_FILE="/provco/OneNetwork/scripts/services"
RESTART_SCRIPT="/provco/OneNetwork/scripts/Restart.sh"
EMAIL="vivek9linux@gmail.com"
TEMP_REPORT="/tmp/service_error_report_$(date +%Y%m%d%H%M).log"
ERROR_PATTERN="java.io.IOException: Connection reset by peer"
DATE_YYYYMMDD=$(date +%Y%m%d)
DATE_DASHED=$(date +%Y-%m-%d)

# Start report
echo "Service Restart Report - $(date)" > "$TEMP_REPORT"
echo "----------------------------------------" >> "$TEMP_REPORT"

# Read each service
while read -r SERVICE; do
  [[ -z "$SERVICE" ]] && continue

  # Find log files matching 3 patterns
  MATCHED_LOGS=$(find "$LOG_DIR" -type f \( \
    -name "${SERVICE}.log" -o \
    -name "${SERVICE}_${DATE_DASHED}*.log" -o \
    -name "${SERVICE}.${DATE_YYYYMMDD}.out" \))

  for LOG in $MATCHED_LOGS; do
    if grep -q "$ERROR_PATTERN" "$LOG"; then
      echo "[ALERT] Error in $SERVICE ($LOG)" >> "$TEMP_REPORT"
      "$RESTART_SCRIPT" "$SERVICE" >> "$TEMP_REPORT" 2>&1
      echo "[ACTION] Restarted $SERVICE" >> "$TEMP_REPORT"
      break  # Skip to next service after first match
    fi
  done
done < "$SERVICES_FILE"

# Email report if any service restarted
if grep -q "Restarted" "$TEMP_REPORT"; then
  mail -s "⚠️ Service Restart Alert - Connection Reset Detected" "$EMAIL" < "$TEMP_REPORT"
fi

# Cleanup
rm -f "$TEMP_REPORT"
