#!/bin/bash

SERVICE_NAME="infra-prov-gateway"
LOG_FILE="/provco/OneNetwork/scripts/log/${SERVICE_NAME}_2025-05-21.log"
ERROR_PATTERN="Connection reset by peer"
EMAIL_TO="your.email@domain.com"
RESTART_SCRIPT="/provco/OneNetwork/scripts/Restart.sh"
TEMP_REPORT="/tmp/${SERVICE_NAME}_alert_$(date +%Y%m%d%H%M%S).log"

# Check for error in log file
if grep -q "${ERROR_PATTERN}" "$LOG_FILE"; then
    echo "[$(date)] ERROR detected in ${SERVICE_NAME} log" > "$TEMP_REPORT"
    echo "Pattern: $ERROR_PATTERN" >> "$TEMP_REPORT"

    # Restart the service
    echo "Restarting service: $SERVICE_NAME" >> "$TEMP_REPORT"
    bash "$RESTART_SCRIPT" "$SERVICE_NAME" >> "$TEMP_REPORT" 2>&1

    # Send email
    mail -s "ALERT: ${SERVICE_NAME} restarted due to error" "$EMAIL_TO" < "$TEMP_REPORT"

    # Append to main log
    cat "$TEMP_REPORT" >> "$LOG_FILE"
    
    # Cleanup
    rm -f "$TEMP_REPORT"
else
    echo "[$(date)] No error found for ${SERVICE_NAME}"
fi
