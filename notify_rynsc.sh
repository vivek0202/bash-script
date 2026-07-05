#!/bin/bash

LOGFILE="/opt/scripts/rsync_debug.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "[$(date)] Starting rsync transfer"

# Example rsync
rsync -avz -e ssh deploy_user@src-server-01.example.internal:/dataserver/lqextracts/ deploy_user@dst-server-01.example.internal:/dataserver/lqextracts/

echo "[$(date)] Rsync Completed"

# Email notification
echo "Rsync job completed" | mail -s "Rsync Completed" your-email@example.com
